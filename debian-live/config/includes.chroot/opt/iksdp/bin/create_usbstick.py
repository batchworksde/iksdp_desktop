import subprocess
import json

def get_unmounted_usb_sticks():
    try:
        # Run lsblk to get information about block devices in JSON format
        result = subprocess.run(["lsblk", "-J"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        if result.returncode != 0:
            print(f"Error running lsblk: {result.stderr}")
            return []

        # Parse the JSON output
        devices = json.loads(result.stdout)
        usb_sticks = []

        # Traverse through the devices to find USB sticks
        for device in devices.get("blockdevices", []):
            num_major = device.get("maj:min").split(":")[0]
            num_minor = device.get("maj:min").split(":")[0]
            mountpoint = device.get("mountpoints")

            # 8 is for scsi or usb devices
            if num_major == "8" and mountpoint[0] == None:
                usb_sticks.append({
                    "name": device["name"],
                })

        return usb_sticks

    except Exception as e:
        print(f"An error occurred: {e}")
        return []

if __name__ == "__main__":
    usb_sticks = get_unmounted_usb_sticks()

    if usb_sticks:
        print("Unmounted USB sticks:")
        n = 0
        for usb in usb_sticks:
            print(f"{n} - Name: {usb['name']}")
            n += 1
    else:
        print("No unmounted USB sticks found.")

    # create a userinput to select the usb stick
    selected_create = input("create a new usbstick or a user [Y/n]: ")
    selected_create = selected_create.lower()

    if selected_create == "y" or selected_create == "":
        print("create a new usbstick")
        selected_usb = int(input("Select the USB stick: "))
        print(f"Selected USB stick: {usb_sticks[selected_usb]['name']}")

        selected_exfat = str(input("add a exfat Windows partition?: [Y/n]"))

        if selected_exfat == "y" or selected_exfat == "":
            selected_exfat_size = input("select the size of Windows partition in percent [50]:")
            if selected_exfat_size == "":
                selected_exfat_size = 50
            print(f"Selected USB stick: {usb_sticks[selected_usb]['name']} with {selected_exfat_size} % exfat partition")




        print(f"Selected USB stick: {usb_sticks[selected_usb]['name']}")




