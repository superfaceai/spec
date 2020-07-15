profile = "http://superface.ai/profile/conversation/SendMessage"

"Send single conversation message"
usecase SendMessage {
  input {
    to
    from
    channel
    text
  }

  result {
    messageId
  }

  async result {
    messageId
    deliveryStatus
  }

  error {
    problem
    detail
    instance
  }

}

"Retrieve status of a sent message"
usecase RetrieveMessageStatus safe {
  input {
    messageId
  }

  result {
    deliveryStatus
  }
}

"Identifier of Message
  The identifier is channel-specific and not unique. It should be treated as an opaque value and only used in subsequent calls"
field messageId: String

"Delivery Status of Message
  Status of a sent message. Harmonized across different channels."
field deliveryStatus Enum {
  accepted
  delivered
  seen
}

field channel Enum {
  sms
  whatsapp
  apple_business_chat
  facebook_messenger
}


model X [ 
  Enum {
    A
    B
  }
]

model A { 

} 

model Y { name } | { email }

field fieldName B! | A!