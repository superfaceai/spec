"""
Send Email Profile

Basic profile for sending emails
"""
profile {
  id: "https://superface.ai/profiles/email/SendEmail"
}

"""
Send Email

Send plain text email
"""
usecase SendEmail @unsafe {
  input {
    "Email address to send email to"
    to: [String!]!
    
    "Email address to send email from"
    from: String!
    
    "Subject of the email"
    subject: String

    "Subject of the email"
    body: String
  }

  result {
    "Id of the message sent"
    id: String
  }

  error {                     # TODO: decide wheter use GQL enum syntax or Array syntax
    RecepientQuotaExceeded
    RateLimit 
  }
}

model RecepientQuotaExceeded {
  quota: Number
  actualNumberOfRecepients: Number
}

model RateLimit {
  # ...
}


