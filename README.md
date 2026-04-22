<p align="center">
  <img src="hxRoku.svg" alt="hxRoku logo" width="320">
</p>

# reflaxe.BrightScript

**A Haxe → BrightScript transpiler for Roku developers who want a modern language without leaving the Roku platform.**

> **Status: Work In Progress.** The compiler already translates a large portion of the Haxe standard library (see the test matrix below), but APIs, emitted code shape, and runtime helpers are still changing. Not recommended for production channels yet — great for experimentation, prototyping, and contributions.

---

## Why write Haxe instead of BrightScript?

BrightScript is simple, and that simplicity is its strength — but day-to-day Roku work runs into the same gaps over and over. This project compiles [Haxe](https://haxe.org) down to BrightScript so you get a modern language on top of the runtime you already ship to.

| Vanilla BrightScript | With Haxe → BrightScript |
|---|---|
| Dynamic typing, errors surface at runtime on-device | Static typing, errors caught at compile time on your laptop |
| No classes — associative arrays + `m` conventions | Real `class`, inheritance, interfaces, abstracts, generics |
| No enums | `enum` and `enum abstract` (tagged unions + typed constants) |
| Ad-hoc error returns, `try`/`catch` only for thrown objects | Typed exceptions with `throw` / `try` / `catch` hierarchies |
| Sparse standard library | Full Haxe std: `Array`, `Map`, `String`, `StringTools`, `Math`, `Date`, `DateTools`, `Xml`, `Json`, `Reflect`, `Type`, `Lambda`, `List`, `EReg` (regex), `StringBuf`, `Bytes`, `haxe.crypto`, `haxe.Serializer`, `haxe.Timer`, `haxe.Http`, `haxe.CallStack` |
| Hand-rolled string helpers | Regular expressions (`EReg`), string interpolation, `StringTools` utilities |
| Manual JSON handling | `haxe.Json.parse` / `stringify` with typed structures |
| No macros or metaprogramming | Haxe macros and compile-time metadata |
| Ecosystem limited to Roku world | Reuse cross-platform Haxe libraries where they don't hit Roku-specific APIs |

You still ship `.brs` — the Roku runtime, scene graph, and channel manifest don't change.

## One codebase, every screen

This is the bigger story. Haxe already compiles to JavaScript, C++, Java, C#, Python, HashLink, and more — so the same app logic you write once can target:

- **Web** (JavaScript / WebAssembly)
- **Smart TVs** (Tizen, webOS, Android TV via JS or Java/Kotlin interop)
- **Mobile** (iOS / Android via C++ or Java)
- **Desktop** (native via C++/HashLink)
- **Roku** (BrightScript — via this project, soon)

Write your state management, models, business rules, and protocol code once in Haxe; compile a different backend for each platform and keep only the thin UI/platform layer native. For multi-platform streaming/video teams, that's the difference between maintaining five near-identical codebases and maintaining one core + five shells.

## How it works

Built on top of [Reflaxe](https://github.com/SomeRanDev/reflaxe), which exposes Haxe's typed AST so custom targets can emit any language. The `brightscript` library maps Haxe constructs onto BrightScript equivalents and ships a `std/` implementation of the Haxe standard library written against BrightScript intrinsics.

Two output modes are supported:

- **File-to-file translation** — each Haxe module becomes its own `.brs` file.
- **One-file amalgamation** — every module is bundled into a single `.brs` file (useful for quick iteration and running under [`@rokucommunity/brs`](https://www.npmjs.com/package/@rokucommunity/brs) from the CLI).

## Quick look

```haxe
class Greeter {
    public function new() {}

    public function greet(names:Array<String>):Void {
        for (name in names) {
            Sys.println('Hello, $name!');
        }
    }
}

class Main {
    public static function main() {
        new Greeter().greet(["Roku", "Haxe"]);
    }
}
```

…compiles to BrightScript that runs under the Roku interpreter or the community `brs` runtime.

## Getting started

You'll need [Haxe](https://haxe.org/download/) and [lix](https://github.com/lix-pm/lix.client) installed globally:

```bash
npm install -g lix    # one-time: install the lix package manager globally
```

Then, inside the project:

```bash
npm install           # pulls Haxe libraries via lix and the brs runtime
npm test              # build the sample suite and run it under brs  ← works today
npm run utest         # build the utest-based suite (runs, but not fully functional yet —
                      #   needs better inheritance handling in the compiler)
```

The sample project under [`sample/`](sample/) exercises the compiler across the standard library — it doubles as a living spec for what works today. The `utest` suite under [`tests/`](tests/) is the next milestone; it executes, but some assertions misbehave until class inheritance lowering is finished.

## What's covered today

The test suite under [`tests/`](tests/) and [`sample/`](sample/) exercises:

Arrays · Strings · StringTools · Math · Maps · Dates & DateTools · Xml · Json · Json printing · Bytes · Serializer · Crypto · CallStack · Reflect · Type · Lambda · List · EReg · StringBuf · Exceptions · Timers · Http · core language features (classes, enums, generics, closures, pattern matching)

Not every corner of every API is wired up yet — expect rough edges and please file issues.

## Project layout

- [`src/brscompiler/`](src/brscompiler/) — the Reflaxe-based compiler (class, field, expression, and type sub-compilers).
- [`std/brs/_std/`](std/brs/_std/) — BrightScript implementations of the Haxe standard library.
- [`sample/`](sample/) — hand-written Haxe programs used as integration tests.
- [`tests/`](tests/) — `utest`-based unit tests.
- [`build.hxml`](build.hxml) — example build configuration.

## Contributing

Issues and PRs are very welcome — especially from Roku/BrightScript developers who hit rough edges in emitted code, or Haxe developers who want to help fill in missing stdlib surfaces. The fastest way to reproduce a bug is to add a minimal case to [`sample/`](sample/) or [`tests/`](tests/) that fails.

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).
