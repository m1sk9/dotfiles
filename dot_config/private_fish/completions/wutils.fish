# Fish completion for wutils

# Disable file completion by default
complete -c wutils -f

# Main commands
complete -c wutils -n __fish_use_subcommand -a time -d 'Adjust end time based on breaks taken'
complete -c wutils -n __fish_use_subcommand -a salary -d 'Calculate total salary from work hours and hourly rate'
complete -c wutils -n __fish_use_subcommand -a help -d 'Print this message or the help of the given subcommand(s)'

# Global options
complete -c wutils -n __fish_use_subcommand -s h -l help -d 'Print help'
complete -c wutils -n __fish_use_subcommand -s V -l version -d 'Print version'

# time subcommand
complete -c wutils -n '__fish_seen_subcommand_from time' -l break -d 'Break start and end times (HH:MM or HH:MM:SS)'
complete -c wutils -n '__fish_seen_subcommand_from time' -s h -l help -d 'Print help'

# salary subcommand
complete -c wutils -n '__fish_seen_subcommand_from salary' -s h -l help -d 'Print help'

# help subcommand
complete -c wutils -n '__fish_seen_subcommand_from help' -a time -d 'Adjust end time based on breaks taken'
complete -c wutils -n '__fish_seen_subcommand_from help' -a salary -d 'Calculate total salary from work hours and hourly rate'
