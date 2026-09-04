# OhMyPosh config
oh-my-posh init pwsh --config G:\configs\nirbhaykwatra.omp.json | Invoke-Expression

# Aliases for regularly accessed folders
# Set-Alias scp  "G:\projects\professional\fever-dreams\scp-directors-cut" 
# Set-Alias ubc-qc "G:\projects\professional\ubc-geering-up\quantum-catastrophe"

# Functions
function work {
    # Create detached session with first window named "qc-git"
    psmux new-session -d -s "work" -n "qc-git"
    psmux send-keys -t "work:qc-git" "cd G:\projects\professional\ubc-geering-up\quantum-catastrophe && lazygit" Enter

    # Create second window named "scp-git"
    psmux new-window -t "work" -n "scp-git"
    psmux send-keys -t "work:scp-git" "cd G:\projects\professional\fever-dreams\scp-directors-cut && lazygit" Enter

    # Attach to the session
    psmux attach-session -t "work"
}
