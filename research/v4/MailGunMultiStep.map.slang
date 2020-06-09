super {
  profile = "https://superface.ai/profiles/email/SendEmail"
  provider = "http://superface.ai/directory/SendGrid"
}

map SendEmail {

  run SendOneEmail forEach(input.email as email) if(true) {

    args {
      domain = /@(.*)/.exec( input.from )[1]
      from = input.from
      to = email
      subject = input.subject
      body = input.body
    }

    result {
      mailId = run.result.rid
    }

  }
}


operation SendOneEmail {
  
  http POST https://api.mailgun.net/v3/${YOUR_DOMAIN_NAME}/messages {    
    security {
      scheme = basic
    }

    set {
      YOUR_DOMAIN_NAME = args.domain
    }

    request multipart/form-data {
      body {
        from = args.from
        to = args.to
        subject = args.subject
        text = args.body
      }
    }

    response 200 application/json {
      return {
        id = body.id
      }
      
      result {
        xxx = 42
      }

      set {
        YOUR_DOMAIN_NAME = 11
      }
    }
  }
}