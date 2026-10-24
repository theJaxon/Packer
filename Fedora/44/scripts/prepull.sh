#!/usr/bin/env bash
# Runs inside the box during `packer build`: checks pinned versions, then pre-pulls images.txt.
set -euo pipefail

: "${KUBERNETES_VERSION:?set by packer}"
: "${IMAGES_FILE:?set by packer}"

pinned_images() { grep -Ev '^[[:space:]]*(#|$)' "$IMAGES_FILE"; }

# 1. The kubeadm the kickstart installed must be exactly the pinned version.
installed=$(kubeadm version -o short)
if [[ "$installed" != "$KUBERNETES_VERSION" ]]; then
  echo "ERROR: kubeadm is $installed but the box is pinned to $KUBERNETES_VERSION." >&2
  exit 1
fi

# 2. Every image kubeadm needs must be pinned in images.txt.
missing=$(comm -23 \
  <(kubeadm config images list --kubernetes-version "$KUBERNETES_VERSION" | sort) \
  <(pinned_images | sort))
if [[ -n "$missing" ]]; then
  echo "ERROR: images.txt is missing images kubeadm $KUBERNETES_VERSION needs:" >&2
  echo "$missing" >&2
  exit 1
fi

systemctl start crio
for image in $(pinned_images); do
  echo "Pulling $image"
  crictl pull "$image"
done

crictl images
