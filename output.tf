output "alarm_arns" {
  value = aws_sns_topic.cis_cloudwatch_alarm.arn
}
