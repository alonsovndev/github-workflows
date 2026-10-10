output "role_arns" {
  description = "ARNs of the created roles, keyed by role name. Pass these as role-arn inputs to the reusable workflows."
  value       = { for name, role in aws_iam_role.github : name => role.arn }
}
