let input = { to: ['z@gooo', 'a@foo' ]}

let a = {
  header: {
    accept: 'application/json'
  },

  body: {
    personalizations: input.to.map((inputEmail) => (
      { to: [ { email: inputEmail }], subject: input.subject }
    ))

    // from.email: input.from
    // content.type: 'text/plain'
    // content.value. parameters.body
  }
}

console.log(a)

