###
# Profile
###

model "location" {
  source = "/somewhere else"
}

# Get Weather
use_case "GetWeather" {
  title = "Get Weather"
  description = "Lorem Ipsum"

  use_case "parameters" {
    use_case "location" {
      model = "${model.location}"
    }
  }

  use_case "result" {
    use_case "temperature" {
      type = "string"
    }
    use_case "unit" {
      type = "string"
    }
    use_case "city" {
      model = "${model.location.city}"
    }
  }

  use_case "errors" {
    use_case "LocationNotFound" {}
  }
}

# -------------------------------------------------------

# could define here or reference and re-use
model "forecast" {
  source = "/somewhere else also"
}

###
# Map
###
map "GetWeather" "http" {
  method = "GET"
  url = "https://api.weather.com/forecast"

  response "200" "application/json" {
    profile = "${use_case.GetWeather.result}"

    mapping {
      temperature = "${model.forecast.temp}"
      city = "${model.forecast.location.city}"
      unit = "F"
    }
  }
}
