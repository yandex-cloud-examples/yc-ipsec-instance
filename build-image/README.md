# Сборка образа strongSwan IPsec Instance

Сборка образа для развёртывания `IPsec Instance` на базе решения [strongSwan](https://github.com/strongswan/strongswan).

[Документация StrongSwan](https://docs.strongswan.org/docs/latest).

## Подготовить рабочее окружение для сборки образа

```bash
# Задать значения переменных используемых в процессе сборки образа
export YC_FOLDER_ID=$(yc config get folder-id)
export YC_ZONE="ru-central1-d"
export YC_SUBNET="default-ru-central1-d"
export YC_TOKEN=$(yc iam create-token)
export YC_SUBNET_ID=$(yc vpc subnet list --jq '.[] | select(.name | contains ($ENV.YC_SUBNET)) | .id')
```

## Запустить сборку образа

```bash
yc compute image delete --name ipsec-instance-ubuntu --folder-id $YC_FOLDER_ID
packer plugins install github.com/hashicorp/yandex
packer validate ipsec.pkr.hcl
packer build ipsec.pkr.hcl
```
