{
  profile: {
    profileId: "https://superface.ai/profiles/email/SendEmail"
  }

  provider: {
    providerId: "http://superface.ai/organizaitons/sendgrid"
  }

  map: {
    mapId: "SendEmail",
    useCaseId: "SendEmail",
    
    steps: [
      {
        condition: "true",
        run: {
          http: {
            method: "POST",
            url: "https://api.sendgrid.com/v3/mail/send",
            security: {}
            urlVariables: {}
            queryParameters: {}

            request: {
              headers: {}
              contentType: "application/json",
              body: {}
            },

            response: {
              status: {}
              headers: {}
            }
          }
        }
      }
    ]
  }
}