variable "kexec_tarball_url" {
  type        = string
  description = "NixOS kexec installer tarball url"
  default     = null
}

# To make this re-usable we maybe should accept a store path here?
variable "nixos_partitioner" {
  type        = string
  description = "nixos partitioner and mount script"
  default     = ""
}

# To make this re-usable we maybe should accept a store path here?
variable "nixos_system" {
  type        = string
  description = "The nixos system to deploy"
  default     = ""
}

variable "target_host" {
  type        = string
  description = "DNS host to deploy to"
}

variable "target_user" {
  type        = string
  description = "SSH user used to connect to the target_host"
  default     = "root"
}

variable "target_port" {
  type        = number
  description = "SSH port used to connect to the target_host"
  default     = 22
}

variable "target_pass" {
  type       = string
  description = "Password used to connect to the target_host"
  default    = null
}

variable "ssh_private_key" {
  type        = string
  description = "Content of private key used to connect to the target_host"
  default     = ""
}

variable "instance_id" {
  type        = string
  description = "The instance id of the target_host, used to track when to reinstall the machine"
  default     = null
}

variable "debug_logging" {
  type        = bool
  description = "Enable debug logging"
  default     = false
}

variable "extra_files_script" {
  type        = string
  description = "A script that should place files in the current directory that will be copied to the targets / directory"
  default     = null
}

variable "disk_encryption_key_scripts" {
  type        = list(object({
    path = string
    script = string
  }))
  description = "Each script will be executed locally. Output of each will be created at the given path to disko during installation. The keys will be not copied to the final system"
  default     = []
}

variable "extra_environment" {
  type        = map(string)
  description = "Extra environment variables to be set during installation. This can be useful to set extra variables for the extra_files_script or disk_encryption_key_scripts"
  default     = {}
}

variable "stop_after_disko" {
  type        = bool
  description = "DEPRECATED: Use `phases` instead. Exit after disko formatting"
  default     = false
}

variable "no_reboot" {
  type        = bool
  description = "DEPRECATED: Use `phases` instead. Do not reboot after installation"
  default     = false
}

variable "phases" {
  type        = list(string)
  description = "Phases to run. See `nixos-anywhere --help` for more information"
  default     = ["kexec", "disko", "install", "reboot"]
}

variable "build_on_remote" {
  type        = bool
  description = "Build the closure on the remote machine instead of building it locally and copying it over"
  default     = false
}

variable "flake" {
  type        = string
  description = "The flake to install the system from"
  default     = ""
}

variable "nixos_generate_config_path" {
  type        = string
  description = "Path to which to write a `hardware-configuration.nix` generated by `nixos-generate-config`. This option cannot be set at the same time as `nixos_facter_path`."
  default     = ""
}

variable "nixos_facter_path" {
  type        = string
  description = "Path to which to write a `facter.json` generated by `nixos-facter`. This option cannot be set at the same time as `nixos_generate_config_path`."
  default     = ""
}