profile https://superface.ai/profiles/email/SendEmail
provider http://superface.ai/directory/SendGrid

map SendEmail {
  set {
    YOUR_DOMAIN_NAME = /@(.*)/.exec( input.from )[1]
  }

  http POST https://api.mailgun.net/v3/${YOUR_DOMAIN_NAME}/messages {    
    
    request multipart/form-data {
      
      queryParameters {
        page = 42
      }

      headers {
        my-header = 'superface-test'
      }

      body {
        from = input.from
        to = input.to
        subject = input.subject
        text = input.body
        domain = YOUR_DOMAIN_NAME
      }
    }

    response 200 {
      result {
        id: headers.['X-Message-ID']
      }
    }
  }
}
