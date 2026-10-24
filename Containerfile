# Use the official Rocky Universal Base Image 10
FROM rockylinux/rockylinux:10-ubi

# Maintainer label
LABEL maintainer="Cody Chapman <cchapman@westgate.bank>"

# Set user to root
USER root

# Install Unbound, OpenSSL, and curl using dnf
# clean all keeps the image size optimized
RUN dnf -y update && \
    dnf -y install unbound unbound-utils unbound-anchor openssl curl procps-ng && \
    dnf clean all

# Create the configuration subdirectory and download the root hints file
RUN mkdir -p /etc/unbound/unbound.conf.d \
    && curl -fsSL -o /etc/unbound/root.hints https://www.internic.net/domain/named.root \
    && curl -fsSL -o /etc/unbound/big-oisd-blocklist.conf https://big.oisd.nl/unbound

RUN rm -f /etc/unbound/root.key
RUN rm -f /etc/unbound/unbound.conf
#RUN unbound-anchor -a /etc/unbound/root.key || true

# Initialize DNSSEC root trust anchor
# RUN unbound-anchor -a "/etc/unbound/root.key"

# Copy unbound.conf to /etc/unbound
COPY unbound.conf /etc/unbound/unbound.conf

# --- FIX: Fix permissions so the non-root 'unbound' user can read the files ---
RUN chown -R unbound:unbound /etc/unbound

# Copying entrypoint.sh to /
COPY entrypoint.sh /entrypoint.sh

# setting execution bit
RUN chmod +x /entrypoint.sh

# Expose DNS ports
EXPOSE 53/udp 53/tcp

# Entrypoint Script
ENTRYPOINT ["/entrypoint.sh"]
# Run Unbound in the foreground
#CMD ["unbound", "-d", "-c", "/etc/unbound/unbound.conf"]
