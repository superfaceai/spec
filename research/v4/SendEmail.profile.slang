"""
Send Email Profile

Basic profile for sending emails
"""
profile https://superface.ai/profiles/email/SendEmail

"""
Send Email

Send plain text email
"""
usecase SendEmail unsafe { 
  input {
    "Email address to send email to"
    to: String!
    
    "Email address to send email from"
    from: String!
    
    "Subject of the email"
    subject: String

    "Subject of the email"
    body: String
  }

  result {
    "Id of the message sent"
    mailId: String
  }

  error {
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



