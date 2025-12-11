cat("\014") # clear console
rm(list = ls())

################################################################################
# Secret Santa emailer with gmailr
#
# HOW TO GET YOUR GMAIL OAUTH CLIENT JSON FILE
# --------------------------------------------
# 1. Go to Google Cloud Console:
#    https://console.cloud.google.com/
#
# 2. Create a project (or use an existing one).
#
# 3. Enable the Gmail API:
#    - In the left menu, choose "APIs & Services" -> "Library"
#    - Search for "Gmail API"
#    - Click it, then click "Enable"
#
# 4. Configure the OAuth consent screen (if prompted):
#    - Go to "APIs & Services" -> "OAuth consent screen"
#    - Choose "External" (if you're just using your own Gmail, that's fine)
#    - Fill in the basic app info (app name, email, etc.)
#    - Save and continue (you can leave most scopes/settings default for testing)
#
# 5. Create OAuth client credentials:
#    - Go to "APIs & Services" -> "Credentials"
#    - Click "Create Credentials" -> "OAuth client ID"
#    - Application type: **Desktop app**
#    - Name it something like "Secret Santa R Script"
#    - Click "Create"
#
# 6. Download the client JSON:
#    - After creating the OAuth client, click the "Download JSON" icon
#    - Save the file somewhere on your machine, e.g.:
#      "/Users/yourname/SecretSanta/gmail_oauth_client.json"
#
# 7. Point gmailr at that JSON in this script using gm_auth_configure(path = ...).
#
# 8. Run gm_auth(email = "you@gmail.com") ONCE interactively:
#    - A browser window will open asking you to authorize the app
#    - After that, gmailr will cache a token (usually in .R/gargle/gargle-oauth)
#
# 9. Very important for GitHub:
#    - **Do not commit the OAuth client JSON or cached token files** to GitHub.
#    - Add them to your .gitignore.
################################################################################

# Packages -----------------------------------------------------------------

# install.packages("gmailr")
# install.packages("tidyverse")

library(gmailr)
library(tidyverse)

# AUTHENTICATION -----------------------------------------------------------

# 1) Configure OAuth client JSON (path to the file you downloaded in step 6)
#    Replace this with the actual path on your machine:
#
# gm_auth_configure(
#   path = "/Users/yourname/SecretSanta/gmail_oauth_client.json"
# )
#
# 2) Authorize Gmail account (only need to do this once interactively):
#
# gm_auth(email = "your_email_here@gmail.com")


# PARTICIPANTS -------------------------------------------------------------

# enter names
names <- c(
  "FRODO",
  "SAM",
  "MERRY",
  "PIPPIN",
  "ARAGORN",
  "LEGOLAS",
  "GIMLI",
  "GANDALF",
  "BOROMIR"
)

# enter emails
emails <- c(
  "mr.frodo@example.com",
  "samwise.the.brave@example.com",
  "merry420@example.com",
  "fool.of.a.took@example.com",
  "aragorn.lives@example.com",
  "legolas.a.diversion@example.com",
  "gimli.son.of.gloin@example.com",
  "gandalf.the.grey@example.com",
  "boromir.dads.favorite@example.com"
)

email_list <- tibble(
  names = names,
  email = emails
)

# FORBIDDEN PAIRS ----------------------------------------------------------
# List forbidden pairs (bidirectional)
# (A, B) pair blocks A -> B and B -> A

forbidden_pairs <- list(
  c("FRODO",   "SAM"),
  c("GIMLI",   "LEGOLAS"),
  c("ARAGORN", "BOROMIR")
  # add/remove pairs as needed
)

# Helper: is a giver/receiver combo forbidden?
is_forbidden_pair <- function(giver, receiver, pairs) {
  any(vapply(
    pairs,
    function(p) giver %in% p && receiver %in% p,
    logical(1)
  ))
}

# ASSIGNMENTS --------------------------------------------------------------

make_assignments <- function(names, forbidden_pairs, max_tries = 10000) {
  n <- length(names)
  
  for (attempt in seq_len(max_tries)) {
    randlist <- sample(names)
    
    assignments <- tibble(
      santa_name  = randlist,
      target_name = dplyr::lead(randlist, default = randlist[1])
    )
    
    # No self-matches
    if (any(assignments$santa_name == assignments$target_name)) next
    
    # Check forbidden pairs
    bad_pair <- FALSE
    for (i in seq_len(nrow(assignments))) {
      giver    <- assignments$santa_name[i]
      receiver <- assignments$target_name[i]
      if (is_forbidden_pair(giver, receiver, forbidden_pairs)) {
        bad_pair <- TRUE
        break
      }
    }
    if (bad_pair) next
    
    # If we get here, it's valid 🎉
    base::message("Found valid assignment after ", attempt, " tries.")
    return(assignments)
  }
  
  stop("Could not find a valid assignment within ", max_tries, " attempts. 
       Try relaxing or changing forbidden pairs.")
}

set.seed(2026)  # for reproducible testing
assignments <- make_assignments(names, forbidden_pairs)
print(assignments)

# EMAIL SENDING ------------------------------------------------------------

for (i in seq_len(nrow(assignments))) {
  santa_name  <- assignments$santa_name[i]
  target_name <- assignments$target_name[i]
  
  # Look up the Santa's email address
  santa_info <- email_list %>%
    filter(names == santa_name)
  
  if (nrow(santa_info) != 1) {
    warning("Missing unique email for ", santa_name, "; skipping.")
    next
  }
  
  santa_email <- santa_info$email
  
  base::message("Emailing ", santa_name, " at ", santa_email,
                " (target: ", target_name, ")")
  
  msg <- gm_mime() |>
    gm_to(santa_email) |>
    gm_from("your_email_here@gmail.com") |>
    gm_subject("Middle-earth Secret Santa 🎅✨") |>
    gm_text_body(
      paste0(
        "Dear ", santa_name, ",\n\n",
        "Ho ho ho from the Shire! 🎄\n\n",
        "Your Secret Santa assignment is: ", target_name, " 🎁\n\n",
        "Please keep it secret, keep it safe.\n\n",
        "– Secret Santa Bot 🤖\n"
      )
    )
  
  # For testing: create drafts instead of sending
  gm_create_draft(msg)
  
  # For actual sending, comment out the line above and uncomment below:
  # gm_send_message(msg)
}
