# ~/.config/fish/functions/awsp.fish
# Usage: awsp clickk | awsp careerplug | awsp (shows current)

function awsp
    if test (count $argv) -eq 0
        if set -q AWS_PROFILE
            echo "Current AWS profile: $AWS_PROFILE"
        else
            echo "No AWS profile set (using default)"
        end
        echo ""
        echo "Available profiles:"
        aws configure list-profiles
        return
    end

    set profile $argv[1]

    # Validate profile exists
    if not aws configure list-profiles | grep -q "^$profile\$"
        echo "Profile '$profile' not found."
        echo "Available profiles:"
        aws configure list-profiles
        return 1
    end

    set -gx AWS_PROFILE $profile
    echo "Switched to AWS profile: $profile"

    # Show current identity
    aws sts get-caller-identity 2>/dev/null && true || echo "Warning: could not verify identity (check your credentials)"
end
