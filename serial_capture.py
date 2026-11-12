
import serial
import csv
import time

PORT = "COM10"
BAUD_RATE = 115200
SAMPLE_COUNT = 16

def main():

    ser = serial.Serial(
        PORT,
        BAUD_RATE,
        timeout=2
    )

    time.sleep(2)

    samples = []

    print("Waiting for Arduino data...")

    try:
        while len(samples) < SAMPLE_COUNT:

            line = ser.readline().decode(
                "utf-8",
                errors="replace"
            ).strip()

            if not line.startswith("S,"):
                continue

            parts = line.split(",")

            if len(parts) != 4:
                continue

            try:
                temperature = int(parts[1])
                speed = int(parts[2])
                voltage = int(parts[3])
            except ValueError:
                continue

            if not (
                200 <= temperature <= 399
                and 0 <= speed <= 119
                and 110 <= voltage <= 139
            ):
                continue

            samples.append(
                (temperature, speed, voltage)
            )

            print(
                f"Sample {len(samples)}: "
                f"T={temperature / 10:.1f} C, "
                f"Speed={speed} km/h, "
                f"Voltage={voltage / 10:.1f} V"
            )

    finally:
        ser.close()

    with open("test_vectors.txt", "w") as f:
        for temperature, speed, voltage in samples:
            f.write(
                f"{temperature} {speed} {voltage}\n"
            )

    with open("sensor_log.csv", "w", newline="") as f:
        writer = csv.writer(f)

        writer.writerow([
            "Temperature_x10",
            "Speed_kmh",
            "Voltage_x10"
        ])

        writer.writerows(samples)

    print("\n16 samples captured successfully.")
    print("Generated test_vectors.txt")
    print("Generated sensor_log.csv")


if __name__ == "__main__":
    main()
