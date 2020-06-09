
operation foo {
  return {
    answer = 42
  }
}

operation bar {
  run foo {
    ok return {
      betterAnswer = foo.return.answer
    }
  }
}

operation countArray {
  set {
    count = 0
  }

  run forEach(args.array as element) {
    set {
      count = count + 1
    }
  }
}

