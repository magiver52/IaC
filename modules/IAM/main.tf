resource "aws_iam_role" "iam_role" {
  for_each = { for item in var.iam_config :
    "${item.project}-${item.application}-${index(var.iam_config, item)}" => {
      "index" : index(var.iam_config, item)
      "project" : item.project
      "application" : item.application
      "path" : item.path
      "ticket" : item.ticket
    }
  }
  name               = join("-", tolist([var.client, each.value["project"], "role", each.value["application"], var.environment]))
  path               = each.value["path"]
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
  tags = merge({ Name = "${join("-", tolist([var.client, each.value["project"], "role", each.value["application"], var.environment]))}" },
    { id_case = each.value["ticket"] },
  { application = each.value["application"] })
}

data "aws_iam_policy_document" "assume_role" {
  for_each = { for item in var.iam_config :
    "${item.project}-${item.application}-${index(var.iam_config, item)}" => {
      "index" : index(var.iam_config, item)
      "type" : item.type
      "identifiers" : item.identifiers
    }
  }
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = each.value["type"]
      identifiers = each.value["identifiers"]
    }
  }
}


data "aws_iam_policy_document" "dynamic_policy" {
  for_each = { for item in flatten([for iam in var.iam_config : [for policy in iam.policies : {
    "role_index" : index(var.iam_config, iam)
    "policy_index" : index(iam.policies, policy)
    "project" : iam.project
    "application" : iam.application
    "ticket" : iam.ticket
    "description" : policy.policy_description
    "policy_statements" : policy.policy_statements
    }]]) :
    "${item.project}-${item.application}-${item.policy_index}" => item if length(item.policy_statements) > 0
  }
  dynamic "statement" {
    for_each = each.value["policy_statements"]
    content {
      sid       = statement.value["sid"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      effect    = statement.value["effect"]

      dynamic "condition" {
        for_each = statement.value["condition"]
        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}

resource "aws_iam_policy" "policy" {
  for_each = { for item in flatten([for iam in var.iam_config : [for policy in iam.policies : {
    "role_index" : index(var.iam_config, iam)
    "policy_index" : index(iam.policies, policy)
    "project" : iam.project
    "application" : iam.application
    "ticket" : iam.ticket
    "description" : policy.policy_description
    "policy_statements" : policy.policy_statements
    }]]) :
    "${item.project}-${item.application}-${item.policy_index}" => item if length(item.policy_statements) > 0
  }
  name        = join("-", tolist([var.client, each.value["project"], var.environment, "policy", each.value["application"], each.value["policy_index"] + 1]))
  description = each.value["description"]
  policy      = data.aws_iam_policy_document.dynamic_policy[each.key].json
  tags = merge({ Name = "${join("-", tolist([var.client, each.value["project"], var.environment, "policy", each.value["application"], each.value["policy_index"] + 1]))}" },
  { id_case = each.value["ticket"] })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  for_each = { for item in flatten([for iam in var.iam_config : [for policy in iam.policies : {
    "role_index" : index(var.iam_config, iam)
    "policy_index" : index(iam.policies, policy)
    "project" : iam.project
    "application" : iam.application
    "ticket" : iam.ticket
    "description" : policy.policy_description
    "policy_statements" : policy.policy_statements
    }]]) :
    "${item.project}-${item.application}-${item.policy_index}" => item if length(item.policy_statements) > 0
  }
  role       = aws_iam_role.iam_role["${each.value.project}-${each.value.application}-${each.value.role_index}"].name
  policy_arn = aws_iam_policy.policy[each.key].arn
}
