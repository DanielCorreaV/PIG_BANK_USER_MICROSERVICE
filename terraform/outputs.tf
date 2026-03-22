output "notification_integration" {
  description = "Configuración de la cola SQS compartida usada para publicar notificaciones"
  value = {
    queue_url = var.notification_queue_url
    queue_arn = var.notification_queue_arn
  }
}