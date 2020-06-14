"""
Send one message
"""
usecase Send Message {
  parameters {
    sender: string
    channel: string   # <- move to "provider" selection
    receiverId: string
    
    content: union {
      text: string
      media: {}
    }
  }

  result {
    messageId: string
  }

  async result {
    deliveryStatus: enum {
      accepted
      delivered
      seen
    }
  }

  error {
    code: string
    details: string
  }
}

"""
Send multiple messages
"""
usecase Send Multiple Messages {
  parameters {

  }

  result {

  }

  async result {

  }
}
