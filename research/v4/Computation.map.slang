
operation foo {
  return {
    answer = 42
  }
}

operation bar {
  run foo {
    ok return {
      betterAnswer = run.return.answer
    }
  }
}

operation countArray {
  set {
    count = 0
  }

  run forEach(args.array) {
    set {
      count = count + 1
    }
  }

  run { 
    return {
      result = 'this is the count: ' + count
    }
  }
}
