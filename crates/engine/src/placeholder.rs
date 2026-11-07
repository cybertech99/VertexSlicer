//! Evaluator for the Bambu / PrusaSlicer "placeholder" template language used in
//! machine start / end / layer-change G-code:
//!   [name]                      value substitution (outside blocks)
//!   {expr}                      evaluated and printed
//!   {if cond} .. {elsif c} .. {else} .. {endif}
//! Expressions: numbers, "strings", identifiers, name[index], f(args), ( ), unary ! - +,
//! * / %, + -, < <= > >=, == !=, && || (and/or), and cond ? a : b.
use std::collections::HashMap;

#[derive(Clone, Debug, PartialEq)]
pub enum Val {
    Num(f64),
    Str(String),
    List(Vec<Val>),
}

impl Val {
    fn truthy(&self) -> bool {
        match self {
            Val::Num(n) => *n != 0.0,
            Val::Str(s) => !s.is_empty(),
            Val::List(l) => !l.is_empty(),
        }
    }
    fn num(&self) -> Result<f64, String> {
        match self {
            Val::Num(n) => Ok(*n),
            Val::Str(s) => s.trim().parse().map_err(|_| format!("'{s}' is not a number")),
            Val::List(_) => Err("list used as a number".into()),
        }
    }
    pub fn from_bool(b: bool) -> Val {
        Val::Num(if b { 1.0 } else { 0.0 })
    }
    pub fn text(&self) -> String {
        match self {
            Val::Num(n) => fmt_g(*n),
            Val::Str(s) => s.clone(),
            Val::List(l) => l.iter().map(|v| v.text()).collect::<Vec<_>>().join(","),
        }
    }
}

/// `%g`-style number formatting (up to 3 decimals, no trailing zeros - matches Bambu Studio).
pub fn fmt_g(x: f64) -> String {
    if x == x.trunc() && x.abs() < 1e15 {
        return format!("{}", x as i64);
    }
    let s = format!("{:.3}", x);
    let s = s.trim_end_matches('0').trim_end_matches('.');
    if s == "-0" { "0".into() } else { s.to_string() }
}

pub type Vars = HashMap<String, Val>;

// ---------------- lexer ----------------

#[derive(Clone, Debug, PartialEq)]
enum Tok {
    Num(f64),
    Str(String),
    Id(String),
    Op(&'static str),
}

fn lex(s: &str) -> Result<Vec<Tok>, String> {
    let c: Vec<char> = s.chars().collect();
    let mut i = 0;
    let mut out = vec![];
    const OPS: [&str; 22] = ["&&", "||", "==", "!=", "<=", ">=", "<", ">", "+", "-", "*", "/", "%", "!", "(", ")", "[", "]", ",", "?", ":", "="];
    while i < c.len() {
        let ch = c[i];
        if ch.is_whitespace() {
            i += 1;
        } else if ch.is_ascii_digit() || (ch == '.' && i + 1 < c.len() && c[i + 1].is_ascii_digit()) {
            let st = i;
            while i < c.len() && (c[i].is_ascii_digit() || c[i] == '.') {
                i += 1;
            }
            let t: String = c[st..i].iter().collect();
            out.push(Tok::Num(t.parse().map_err(|_| format!("bad number '{t}'"))?));
        } else if ch == '"' || ch == '\'' {
            let q = ch;
            i += 1;
            let st = i;
            while i < c.len() && c[i] != q {
                i += 1;
            }
            if i >= c.len() {
                return Err("unterminated string".into());
            }
            out.push(Tok::Str(c[st..i].iter().collect()));
            i += 1;
        } else if ch.is_alphabetic() || ch == '_' {
            let st = i;
            while i < c.len() && (c[i].is_alphanumeric() || c[i] == '_') {
                i += 1;
            }
            let t: String = c[st..i].iter().collect();
            match t.as_str() {
                "and" => out.push(Tok::Op("&&")),
                "or" => out.push(Tok::Op("||")),
                "not" => out.push(Tok::Op("!")),
                _ => out.push(Tok::Id(t)),
            }
        } else {
            let rest: String = c[i..c.len().min(i + 2)].iter().collect();
            let op = OPS.iter().find(|o| rest.starts_with(**o)).ok_or_else(|| format!("unexpected character '{ch}'"))?;
            i += op.len();
            out.push(Tok::Op(op));
        }
    }
    Ok(out)
}

// ---------------- parser / evaluator (single pass) ----------------

struct Ev<'a> {
    t: Vec<Tok>,
    p: usize,
    vars: &'a Vars,
    /// when false, parse without evaluating side-effect-free branches' errors (short-circuit)
    live: bool,
}

impl<'a> Ev<'a> {
    fn peek(&self) -> Option<&Tok> {
        self.t.get(self.p)
    }
    fn eat(&mut self, op: &str) -> bool {
        if matches!(self.peek(), Some(Tok::Op(o)) if *o == op) {
            self.p += 1;
            true
        } else {
            false
        }
    }
    fn expect(&mut self, op: &str) -> Result<(), String> {
        if self.eat(op) { Ok(()) } else { Err(format!("expected '{op}'")) }
    }

    fn ternary(&mut self) -> Result<Val, String> {
        let c = self.or()?;
        if self.eat("?") {
            let live = self.live;
            let cond = c.truthy();
            self.live = live && cond;
            let a = self.ternary()?;
            self.expect(":")?;
            self.live = live && !cond;
            let b = self.ternary()?;
            self.live = live;
            return Ok(if cond { a } else { b });
        }
        Ok(c)
    }
    fn or(&mut self) -> Result<Val, String> {
        let mut l = self.and()?;
        while self.eat("||") {
            let live = self.live;
            self.live = live && !l.truthy();
            let r = self.and()?;
            self.live = live;
            l = Val::from_bool(l.truthy() || r.truthy());
        }
        Ok(l)
    }
    fn and(&mut self) -> Result<Val, String> {
        let mut l = self.eq()?;
        while self.eat("&&") {
            let live = self.live;
            self.live = live && l.truthy();
            let r = self.eq()?;
            self.live = live;
            l = Val::from_bool(l.truthy() && r.truthy());
        }
        Ok(l)
    }
    fn eq(&mut self) -> Result<Val, String> {
        let mut l = self.cmp()?;
        loop {
            let neg = if self.eat("==") { false } else if self.eat("!=") { true } else { break };
            let r = self.cmp()?;
            let same = match (&l, &r) {
                (Val::Num(a), Val::Num(b)) => (a - b).abs() < 1e-9,
                (Val::Str(a), Val::Str(b)) => a == b,
                (Val::Num(a), Val::Str(b)) | (Val::Str(b), Val::Num(a)) => b.trim().parse::<f64>().map(|x| (x - a).abs() < 1e-9).unwrap_or(false),
                _ => false,
            };
            l = Val::from_bool(same != neg);
        }
        Ok(l)
    }
    fn cmp(&mut self) -> Result<Val, String> {
        let mut l = self.add()?;
        loop {
            let op = ["<=", ">=", "<", ">"].into_iter().find(|o| self.eat(o));
            let Some(op) = op else { break };
            let r = self.add()?;
            if !self.live {
                l = Val::Num(0.0);
                continue;
            }
            let (a, b) = (l.num()?, r.num()?);
            l = Val::from_bool(match op {
                "<=" => a <= b,
                ">=" => a >= b,
                "<" => a < b,
                _ => a > b,
            });
        }
        Ok(l)
    }
    fn add(&mut self) -> Result<Val, String> {
        let mut l = self.mul()?;
        loop {
            let plus = if self.eat("+") { true } else if self.eat("-") { false } else { break };
            let r = self.mul()?;
            if !self.live {
                continue;
            }
            l = match (&l, &r, plus) {
                (Val::Str(a), Val::Str(b), true) => Val::Str(format!("{a}{b}")),
                _ => Val::Num(if plus { l.num()? + r.num()? } else { l.num()? - r.num()? }),
            };
        }
        Ok(l)
    }
    fn mul(&mut self) -> Result<Val, String> {
        let mut l = self.unary()?;
        loop {
            let op = ["*", "/", "%"].into_iter().find(|o| self.eat(o));
            let Some(op) = op else { break };
            let r = self.unary()?;
            if !self.live {
                continue;
            }
            let (a, b) = (l.num()?, r.num()?);
            l = Val::Num(match op {
                "*" => a * b,
                "/" => {
                    if b == 0.0 {
                        return Err("division by zero".into());
                    }
                    a / b
                }
                _ => {
                    if b == 0.0 {
                        return Err("modulo by zero".into());
                    }
                    a % b
                }
            });
        }
        Ok(l)
    }
    fn unary(&mut self) -> Result<Val, String> {
        if self.eat("!") {
            let v = self.unary()?;
            return Ok(Val::from_bool(!v.truthy()));
        }
        if self.eat("-") {
            let v = self.unary()?;
            return Ok(if self.live { Val::Num(-v.num()?) } else { v });
        }
        if self.eat("+") {
            return self.unary();
        }
        self.postfix()
    }
    fn postfix(&mut self) -> Result<Val, String> {
        let mut v = self.primary()?;
        while self.eat("[") {
            let idx = self.ternary()?;
            self.expect("]")?;
            if !self.live {
                v = Val::Num(0.0);
                continue;
            }
            let i = idx.num()?;
            v = match &v {
                Val::List(l) => {
                    let k = i as i64;
                    if k < 0 || k as usize >= l.len() {
                        return Err(format!("index {k} out of range (len {})", l.len()));
                    }
                    l[k as usize].clone()
                }
                // scalars behave like a one-element list
                other if i == 0.0 => other.clone(),
                _ => return Err("indexing a non-list value".into()),
            };
        }
        Ok(v)
    }
    fn primary(&mut self) -> Result<Val, String> {
        match self.peek().cloned() {
            Some(Tok::Num(n)) => {
                self.p += 1;
                Ok(Val::Num(n))
            }
            Some(Tok::Str(s)) => {
                self.p += 1;
                Ok(Val::Str(s))
            }
            Some(Tok::Op("(")) => {
                self.p += 1;
                let v = self.ternary()?;
                self.expect(")")?;
                Ok(v)
            }
            Some(Tok::Id(name)) => {
                self.p += 1;
                if self.eat("(") {
                    let mut args = vec![];
                    if !self.eat(")") {
                        loop {
                            args.push(self.ternary()?);
                            if self.eat(")") {
                                break;
                            }
                            self.expect(",")?;
                        }
                    }
                    if !self.live {
                        return Ok(Val::Num(0.0));
                    }
                    return call(&name, &args);
                }
                if !self.live {
                    return Ok(self.vars.get(&name).cloned().unwrap_or(Val::Num(0.0)));
                }
                self.vars.get(&name).cloned().ok_or_else(|| format!("unknown variable '{name}'"))
            }
            other => Err(format!("unexpected token {other:?}")),
        }
    }
}

fn call(name: &str, a: &[Val]) -> Result<Val, String> {
    let n = |i: usize| -> Result<f64, String> { a.get(i).ok_or_else(|| format!("{name}: missing argument"))?.num() };
    Ok(Val::Num(match name {
        "max" => a.iter().map(|v| v.num()).collect::<Result<Vec<_>, _>>()?.into_iter().fold(f64::MIN, f64::max),
        "min" => a.iter().map(|v| v.num()).collect::<Result<Vec<_>, _>>()?.into_iter().fold(f64::MAX, f64::min),
        "abs" => n(0)?.abs(),
        "ceil" => n(0)?.ceil(),
        "floor" => n(0)?.floor(),
        "round" => n(0)?.round(),
        "int" => n(0)?.trunc(),
        _ => return Err(format!("unknown function '{name}'")),
    }))
}

pub fn eval_expr(src: &str, vars: &Vars) -> Result<Val, String> {
    let t = lex(src)?;
    let mut ev = Ev { t, p: 0, vars, live: true };
    let v = ev.ternary()?;
    if ev.p != ev.t.len() {
        return Err(format!("trailing tokens in '{}'", src.trim()));
    }
    Ok(v)
}

// ---------------- template ----------------

#[derive(Debug)]
enum Node {
    Text(String),
    Subst(String),
    Expr(String),
    If(Vec<(Option<String>, Vec<Node>)>),
}

fn parse(tpl: &str) -> Result<Vec<Node>, String> {
    // stack of (branches so far, current branch nodes, current condition)
    struct Frame {
        branches: Vec<(Option<String>, Vec<Node>)>,
        cond: Option<String>,
        nodes: Vec<Node>,
    }
    let mut root: Vec<Node> = vec![];
    let mut stack: Vec<Frame> = vec![];
    let cur = |root: &mut Vec<Node>, stack: &mut Vec<Frame>| -> *mut Vec<Node> {
        match stack.last_mut() {
            Some(f) => &mut f.nodes as *mut _,
            None => root as *mut _,
        }
    };
    let b: Vec<char> = tpl.chars().collect();
    let mut i = 0;
    let mut text = String::new();
    macro_rules! flush {
        () => {
            if !text.is_empty() {
                let t = std::mem::take(&mut text);
                unsafe { (*cur(&mut root, &mut stack)).push(Node::Text(t)) }
            }
        };
    }
    while i < b.len() {
        match b[i] {
            '{' => {
                let Some(end) = b[i..].iter().position(|&c| c == '}') else { return Err("unclosed '{'".into()) };
                let inner: String = b[i + 1..i + end].iter().collect();
                i += end + 1;
                flush!();
                let s = inner.trim();
                let kw = s.split(|c: char| c.is_whitespace() || c == '(').next().unwrap_or("");
                match kw {
                    "if" => stack.push(Frame { branches: vec![], cond: Some(s[2..].trim().to_string()), nodes: vec![] }),
                    "elsif" | "else" => {
                        let f = stack.last_mut().ok_or("elsif/else without if")?;
                        let done = (f.cond.take(), std::mem::take(&mut f.nodes));
                        f.branches.push(done);
                        f.cond = if kw == "elsif" { Some(s[5..].trim().to_string()) } else { None };
                        if kw == "else" {
                            f.cond = None;
                        }
                    }
                    "endif" => {
                        let mut f = stack.pop().ok_or("endif without if")?;
                        f.branches.push((f.cond.take(), std::mem::take(&mut f.nodes)));
                        unsafe { (*cur(&mut root, &mut stack)).push(Node::If(f.branches)) }
                    }
                    _ => unsafe { (*cur(&mut root, &mut stack)).push(Node::Expr(s.to_string())) },
                }
            }
            '[' => {
                // [name] substitution (only plain identifiers; otherwise literal text)
                if let Some(end) = b[i..].iter().position(|&c| c == ']') {
                    let name: String = b[i + 1..i + end].iter().collect();
                    if !name.is_empty() && name.chars().all(|c| c.is_alphanumeric() || c == '_') && !name.chars().all(|c| c.is_ascii_digit()) {
                        flush!();
                        unsafe { (*cur(&mut root, &mut stack)).push(Node::Subst(name)) }
                        i += end + 1;
                        continue;
                    }
                }
                text.push('[');
                i += 1;
            }
            c => {
                text.push(c);
                i += 1;
            }
        }
    }
    flush!();
    if !stack.is_empty() {
        return Err("missing {endif}".into());
    }
    Ok(root)
}

fn render_nodes(nodes: &[Node], vars: &Vars, out: &mut String) -> Result<(), String> {
    for n in nodes {
        match n {
            Node::Text(t) => out.push_str(t),
            Node::Subst(name) => match vars.get(name) {
                Some(v) => out.push_str(&v.text()),
                None => out.push_str(&format!("[{name}]")),
            },
            Node::Expr(e) => out.push_str(&eval_expr(e, vars).map_err(|m| format!("in {{{e}}}: {m}"))?.text()),
            Node::If(branches) => {
                for (cond, body) in branches {
                    let take = match cond {
                        Some(c) => eval_expr(c, vars).map_err(|m| format!("in {{if {c}}}: {m}"))?.truthy(),
                        None => true,
                    };
                    if take {
                        render_nodes(body, vars, out)?;
                        break;
                    }
                }
            }
        }
    }
    Ok(())
}

/// Render a template. Lines that contain only a block tag leave no blank line behind.
pub fn render(tpl: &str, vars: &Vars) -> Result<String, String> {
    let nodes = parse(tpl)?;
    let mut out = String::new();
    render_nodes(&nodes, vars, &mut out)?;
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn vars() -> Vars {
        let mut v = Vars::new();
        v.insert("n".into(), Val::Num(5.0));
        v.insert("t".into(), Val::List(vec![Val::Str("PLA".into()), Val::Str("ABS".into())]));
        v.insert("d".into(), Val::List(vec![Val::Num(0.4), Val::Num(0.2)]));
        v.insert("z".into(), Val::Num(10.0));
        v
    }
    fn ev(s: &str) -> Val {
        eval_expr(s, &vars()).unwrap()
    }

    #[test]
    fn arithmetic_and_precedence() {
        assert_eq!(ev("1 + 2 * 3"), Val::Num(7.0));
        assert_eq!(ev("(1+2)*3"), Val::Num(9.0));
        assert_eq!(ev("z + 100.0 - z/2"), Val::Num(105.0));
        assert_eq!(ev("7 % 4"), Val::Num(3.0));
        assert_eq!(ev("-n + 2"), Val::Num(-3.0));
        assert_eq!(ev("max(3, n, 4)"), Val::Num(5.0));
    }

    #[test]
    fn logic_comparison_indexing() {
        assert_eq!(ev("t[1] == \"ABS\""), Val::Num(1.0));
        assert_eq!(ev("d[1] == 0.2"), Val::Num(1.0));
        assert_eq!(ev("!(n >= 6) && (t[0] == \"PLA\" || t[0] == \"PETG\")"), Val::Num(1.0));
        assert_eq!(ev("n > 3 ? 11 : 22"), Val::Num(11.0));
        assert_eq!(ev("t[(n > 3 ? 1 : 0)]"), Val::Str("ABS".into()));
    }

    #[test]
    fn short_circuit_skips_errors() {
        // the unknown variable and the out-of-range index are never evaluated
        assert_eq!(ev("n > 3 ? 1 : missing_var"), Val::Num(1.0));
        assert_eq!(ev("n < 3 && t[9] == \"x\""), Val::Num(0.0));
    }

    #[test]
    fn templates() {
        let tpl = "A[n]\n{if n > 9}big\n{elsif n > 3}mid {n*2}\n{else}small\n{endif}Z";
        assert_eq!(render(tpl, &vars()).unwrap(), "A5\nmid 10\nZ");
        let nested = "{if n > 1}{if t[0] == \"PLA\"}pla{else}other{endif}{else}no{endif}";
        assert_eq!(render(nested, &vars()).unwrap(), "pla");
        // unknown [x] stays literal; numbers keep %g formatting
        assert_eq!(render("G1 [unknown] [0] {0.50} {z+0.4}", &vars()).unwrap(), "G1 [unknown] [0] 0.5 10.4");
    }

    #[test]
    fn errors_are_reported() {
        assert!(render("{nope}", &vars()).is_err());
        assert!(render("{if n}x", &vars()).is_err());
    }
}
