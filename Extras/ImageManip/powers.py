first_sector = 94208
i=1
res = 1
while res < 5000:
    res = 2**i
    print("2**{}={}".format(i, res))
    i += 1
block_count = 682573
device_size = 680712
a = (block_count, device_size, block_count - device_size)
for count in a:
    _bytes = count * 4096
    sectors = _bytes / 512
    if _bytes % 512:
        warning = "    There's a remainder!"
    else:
        warning = ''
    print("Blocks: {}; Bytes: {}; Sectors: {};{}"
        .format(count, _bytes, sectors, warning))
    final_sector = (first_sector - 1) + (count * 4096 / 512)
    print("final sector is {}".format(final_sector))


