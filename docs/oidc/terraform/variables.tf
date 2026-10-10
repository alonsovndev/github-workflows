variable "create_provider" {
  description = "Create the GitHub OIDC provider. Set false when the account already has one (an account can hold only one per URL)."
  type        = bool
  default     = true
}

variable "roles" {
  description = "IAM roles GitHub Actions may assume, keyed by role name."
  type = map(object({
    # Full OIDC subject claims, for example "repo:owner/repo:pull_request",
    # "repo:owner/repo:environment:prod", "repo:owner/repo:ref:refs/heads/main",
    # or "repo:owner/repo:ref:refs/tags/v*". The owner and repository must be literal.
    subjects            = list(string)
    managed_policy_arns = optional(list(string), [])
    inline_policy_json  = optional(string)
  }))

  validation {
    condition = alltrue([
      for role in values(var.roles) :
      length(role.subjects) > 0 && alltrue([
        for subject in role.subjects :
        # A literal owner/repo followed by a claim, so "repo:owner/*" and "repo:*/x" are rejected.
        can(regex("^repo:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+:.+$", subject)) && !endswith(subject, ":*")
      ])
    ])
    error_message = "Every role needs at least one subject of the form repo:<owner>/<repo>:<claim>, naming one repository and one claim (no bare \":*\")."
  }
}
