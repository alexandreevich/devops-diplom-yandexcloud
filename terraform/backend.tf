terraform { 
  cloud { 
    
    organization = "alexadnreevich_company" 

    workspaces { 
      name = "infra-space" 
    } 
  } 
}