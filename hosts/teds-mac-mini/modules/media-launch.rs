use std::env;
use std::os::unix::process::CommandExt;
use std::process::{Command, exit};

fn main() {
    let mut args = env::args_os().skip(1);
    let Some(program) = args.next() else {
        eprintln!("usage: media-launch program [args...]");
        exit(64);
    };
    let err = Command::new(&program).args(args).exec();
    eprintln!("{}: {err}", program.to_string_lossy());
    exit(127);
}
