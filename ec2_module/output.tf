output "public_ip" {
  value       = "${aws_instance.this.public_ip}"
  description = "Mostra o IP privados da maquina criada."
}