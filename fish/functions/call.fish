function call
    pactl set-card-profile bluez_card.80_99_E7_D4_A4_8C headset-head-unit
    echo "Headset mic enabled (HSP/HFP mode)"
end

function endcall
    pactl set-card-profile bluez_card.80_99_E7_D4_A4_8C a2dp-sink
    echo "Back to high quality audio (A2DP)"
end
