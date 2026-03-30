output "sample_file_filename" {
  description = "Sample file name"
  value = local_file.sample.filename
}

output "sample_file_hash_sha1" {
  description = "Sample file sha1"
  value = local_file.sample.content_sha1
}