#======================================
# Install snapd and bootstrap snaps
#--------------------------------------

# The list of profiles is comma separated; change them to spaces to iterate
# over them.
for profile in ${kiwi_profiles//,/ }; do
    if [ "${profile}" = "development" ]; then
        # Use the preseeding feature of snapd to preload some snaps into the
        # system. This will download the snaps from the global Snap Store, copy
        # them to the snapd seed directory, and add each to the preseed YAML
        # file to instruct snapd to install them on first boot.
        # This requires network access to the Snap Store in Kiwi.
        mkdir -p /var/lib/snapd/seed
        echo "snaps": > /var/lib/snapd/seed/seed.yaml
        for snap in snapd checkbox22 checkbox core22; do
            snap download $snap
            # Add this new snap to the list of seeded snaps
            cat >> /var/lib/snapd/seed/seed.yaml << EOF
  - name: ${snap}
    channel: latest/stable
    file: $(ls ${snap}_*.snap)
EOF
            # Checkbox snap requires classic confinement mode
            if [ "${snap}" = "checkbox" ]; then
                cat >> /var/lib/snapd/seed/seed.yaml << EOF
    classic: true
EOF
            fi
        done

        # Copy the snap archives
        install -Dm0644 *.snap -t /var/lib/snapd/seed/snaps/
        # Copy the snap assertions (cryptographic signatures)
        install -Dm0644 *.assert -t /var/lib/snapd/seed/assertions/

        # Install the generic snapd model assertion so that the snaps can
        # be verified and snapd properly initialised.
        snap known --remote model series=16 brand-id=generic \
            model=generic-classic > /var/lib/snapd/seed/assertions/model
    fi
done

rm -f *.snap *.assert
