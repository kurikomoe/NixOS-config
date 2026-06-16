对于中国境内的 VPS，最好的方法还是 dd 部署

```
nix build .#images

xz -T0 -c result/main.raw | ssh root@c.0v0.io "xz -d | dd of=/dev/vda bs=64M status=progress conv=fsync"
```

最后是在 rescure 模式下（能联网）进行 dd

btrfs 需要手动 resize 一下扩容：
```
btrfs filesystem resize max /
```
