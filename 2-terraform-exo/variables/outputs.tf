
output "first_name" {
  description = "Le prénom de l'étudiant"
  value       = var.first_name
}


output "last_name" {
  description = "Le nom de l'étudiant"
  value       = var.last_name
}


output "age" {
  description = "L'âge de l'étudiant"
  value       = var.age
}


output "is_student" {
  description = "Indique si la personne est un étudiant"
  value       = var.is_student
}


output "courses" {
  description = "Liste des cours suivis"
  value       = var.courses
}


output "grades" {
  description = "Notes obtenues par cours"
  value       = var.grades
}


output "student" {
  description = "Objet complet représentant l'étudiant"
  value       = var.student
}


output "student_first_name" {
  value = var.student.first_name
}


output "student_courses" {
  value = var.student.courses
}


output "terraform_grade" {
  value = var.student.grades["terraform"]
}

output "student_locals" {
  value = local.student.age
}


output "identity"{
  value = local.identity
}

output "status" {
  value = local.status
}
