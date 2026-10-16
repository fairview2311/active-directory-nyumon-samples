# まとまり1: IP アドレスとパスワードを覚えさせる
MYIP=203.0.113.10
read -s -p "パスワード: " PW; echo
read -s -p "もう一度: " PW2; echo
[ "$PW" = "$PW2" ] && echo "OK" || echo "違います。まとまり1をやり直す"

# まとまり2: 仮想マシンを作る機能を登録する
az provider register --namespace Microsoft.Compute --wait

# まとまり3: 通り道の決まり（リモートデスクトップは自分の IP アドレスからだけ）
az network nsg create -g rg-midori -n nsg-midori -o none
az network nsg rule create -g rg-midori --nsg-name nsg-midori \
  -n RDP --priority 300 --access Allow --protocol Tcp \
  --direction Inbound --source-address-prefixes "$MYIP/32" \
  --destination-port-ranges 3389 -o none

# まとまり4: DC01
az vm create -g rg-midori -n DC01 \
  --image MicrosoftWindowsServer:WindowsServer:2025-datacenter-g2:latest \
  --size Standard_B2als_v2 \
  --vnet-name vnet-midori --subnet default \
  --private-ip-address 10.0.0.4 --nsg nsg-midori \
  --public-ip-sku Standard \
  --admin-username midoriadmin --admin-password "$PW" \
  --storage-sku StandardSSD_LRS \
  --data-disk-sizes-gb 32 --data-disk-caching None -o table

# まとまり5: PC01
az vm create -g rg-midori -n PC01 \
  --image MicrosoftWindowsDesktop:windows-11:win11-25h2-pro:latest \
  --size Standard_B2als_v2 \
  --vnet-name vnet-midori --subnet default \
  --private-ip-address 10.0.0.5 --nsg nsg-midori \
  --public-ip-sku Standard \
  --admin-username midoriadmin --admin-password "$PW" \
  --storage-sku StandardSSD_LRS -o table

# まとまり6: 毎日 23:00（日本時間）に自動で止める
az vm auto-shutdown -g rg-midori -n DC01 --time 1400 -o none
az vm auto-shutdown -g rg-midori -n PC01 --time 1400 -o none
