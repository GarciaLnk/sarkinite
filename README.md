# Sarkinite

This is a heavily opiniated fork of [Bluefin](https://github.com/ublue-os/bluefin) intended for personal use.

## Secure Boot

Secure Boot is supported by default, providing an additional layer of security. After the first installation, you will be prompted to enroll the secure boot key in the BIOS.

Enter the password `ublue-os`
when prompted to enroll our key.

If this step is not completed during the initial setup, you can manually enroll the key by running the following command in the terminal:

`ujust enroll-secure-boot-key`

Secure boot is supported with our custom key. The pub key can be found in the root of the bazzite repository [here](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der).
If you'd like to enroll this key prior to installation or rebase, download the key and run the following:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

### Note

If you encounter an issue with a password being recognized as incorrect, try using the `-` key on the numpad instead.
