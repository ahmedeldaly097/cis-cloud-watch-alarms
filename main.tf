terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region  = "us-east-2"
  profile = terraform.workspace
}

# Configure SNS Topic
resource "aws_sns_topic" "cis_cloudwatch_alarm" {
  name         = "cis-cloudwatch-alarm"
  display_name = "CIS-Cloudwatch-Alarm"
}

# Configure SNS Topic Subscription
resource "aws_sns_topic_subscription" "cis_cloudwatch_alarm_target" {
  topic_arn = aws_sns_topic.cis_cloudwatch_alarm.arn
  protocol  = "email"
  endpoint  = "aeldaly@novomind-mea.com"
}

# Configure a log metric filter
locals {
  metric_filters = {
    for index, resource_type in var.resource_type : resource_type => {
      name    = "cis-metric-filter-${resource_type}-changes"
      pattern = var.metric_filter[index]
    }
  }
}

resource "aws_cloudwatch_log_metric_filter" "cis_metric_filter" {
  for_each       = local.metric_filters
  name           = each.value.name
  pattern        = each.value.pattern
  log_group_name = "aws-controltower/CloudTrailLogs"

  metric_transformation {
    name      = "cis-metric-${each.key}-changes"
    namespace = "cis-log-metrics"
    value     = "1"
  }
}

# Configure a metric alarm
resource "aws_cloudwatch_metric_alarm" "cis_metric_alarm" {
  for_each                  = aws_cloudwatch_log_metric_filter.cis_metric_filter
  alarm_name                = "cis-metric-${each.key}-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = each.value.metric_transformation[0].name
  namespace                 = each.value.metric_transformation[0].namespace
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "This metric monitors ${each.key} changes"
  insufficient_data_actions = []

  actions_enabled = true
  alarm_actions   = [aws_sns_topic.cis_cloudwatch_alarm.arn]
}
