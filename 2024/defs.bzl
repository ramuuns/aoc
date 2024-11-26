load("@rules_python//python:defs.bzl", "py_binary", "py_library", "py_test")

def aoc_day(day, fetch_input = True):
    native.genrule(
        name = "test_runner_{}".format(day),
        outs = ["test_runner_{}.py".format(day)],
        cmd = """
            echo "module = __import__(\\\"day{}\\\")\nmodule.test()\n" > "$@"
        """.format(day)
        )

    if fetch_input:
      native.genrule(
          name = "day_runner_{}".format(day),
          outs = ["day_runner_{}.py".format(day)],
          cmd = """
              echo "module = __import__(\\\"day{}\\\")\nf = open(\\\"input-{}.in\\\",\\\"r\\\")\ndata = f.read().rstrip()\np1,p2 = module.run(data)\nprint(p1)\nprint(p2)\n" > "$@"
          """.format(day, day)
      )
    else:
      native.genrule(
          name = "day_runner_{}".format(day),
          outs = ["day_runner_{}.py".format(day)],
          cmd = """
              echo "module = __import__(\\\"day{}\\\")\nf = open(\\\"input-{}\\\",\\\"r\\\")\ndata = f.read().rstrip()\np1,p2 = module.run(data)\nprint(p1)\nprint(p2)\n" > "$@"
          """.format(day, day)
      )

    day_no_padding = day
    if day.startswith("0"):
      day_no_padding = day[1:]

    if fetch_input:
      get_stuff(
        url = "https://adventofcode.com/2024/day/{}/input".format(day_no_padding),
        cookie = ":COOKIE",
        name = "input-{}".format(day)
      )

    py_test(
        name = "test_{}".format(day),
        srcs = ["day{}.py".format(day), ":test_runner_{}".format(day)],
        main = "test_runner_{}.py".format(day),
    )

    py_binary(
        name = "day_{}".format(day),
        srcs = ["day{}.py".format(day), ":day_runner_{}".format(day)],
        main = "day_runner_{}.py".format(day),
        data = [":input-{}".format(day)]
    )


def _impl(ctx):
    ctx.actions.run_shell(
        inputs = [ctx.file.cookie],
        outputs = [ctx.outputs.out],
        command = "curl -L -s -H \"{}\" -H \"Cookie: $(cat {})\" {} > {}".format("User-Agent: github.com/ramuuns/aoc/blob/master/2023/make_day.sh by ramuuns@ramuuns.com", ctx.file.cookie.path, ctx.attr.url, ctx.outputs.out.path)
    )

get_stuff = rule(
    _impl,
    attrs = {
        "url": attr.string(
            mandatory = True,
        ),
        "cookie": attr.label(
            mandatory = True,
            allow_single_file = True,
        )
    },
    outputs = {"out": "%{name}.in"},
)
