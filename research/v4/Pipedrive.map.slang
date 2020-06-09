profile http://supermodel.io/superface/CRM/Customers
provider http://superface.ai/directory/Pipedrive

map RetrieveCustomers {
  # Local variables
  set {
    filterId = null
  }

  # Step 1
  run FindFilter if(input.since) {
    args {
      filterName = "my-superface-map-filter"
    }

    ok {
      set {
        filterId = run.result.filterId
      }
    }
  }

  # Step 2
  run CreateFilter if(input.since && !filterId) {
    args {
      filterId = filterId
    }

    ok set {  # slang shorthand
      filterId = run.result.filterId
    }
  }

  # Step 3
  run RetrieveOrganizations {
    args {
      filterId = filterId
    }

    ok result {
      customers = run.result.customers
    }
  }

  # Step 4
  run Cleanup if(filterId) {

  }
}

operation FindFilter {

}

operation CreateFilter {

}

operation RetrieveOrganizations {

}





