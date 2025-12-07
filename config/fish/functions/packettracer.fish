function packettracer --wraps='QT_QPA_PLATFORM=xcb /opt/pt/packettracer' --description 'alias packettracer QT_QPA_PLATFORM=xcb /opt/pt/packettracer'
    QT_QPA_PLATFORM=xcb /opt/pt/packettracer $argv
end
