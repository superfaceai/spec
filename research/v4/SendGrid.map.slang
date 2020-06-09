profile https://superface.ai/profiles/email/SendEmail
provider http://superface.ai/directory/SendGrid

map B {
  run SendEmailNetwork {
    result {

    }
  }
}

map A {
  run X {
    result {

    }
  }
}

map B {
  run X {
    result {

    }
  }
}

operation X {

}

operation SendEmailNetwork {
  http POST https://api.sendgrid.com/v3/mail/send {

    request application/json {
      
      security {
        scheme: basic
      }

      headers {
        accept: 'application/json'
      }

      body {
        personalizations: input.to.map((inputEmail) => (
          { to: [ { email: inputEmail }] subject: input.subject }
        )
        from.email = input.from
        content.type = 'text/plain'
        content.value = input.body
      }
    }

    response 200 application/json {
      
      return {
        id = headers.'X-Message-Id'
        name = body.username
        username = body.name
      }
    }
  }  
}