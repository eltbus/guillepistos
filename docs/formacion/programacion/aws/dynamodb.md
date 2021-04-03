# Introduccion
DynamoDB mola.

Como con otros productos de AWS, usar mucho `--dryrun` para previsualizar el resultado antes de que se ejecute.

## Crear, borrar y actualizar una tabla
Si.

## Operaciones sobre una tabla
Podemos hacer las siguientes operaciones

### CREATE-TABLE
```bash
aws dynamodb create-table --table-name '<table_name>' --attribute-definitions 'AttributeName=primary_key,AttributeType=S AttributeName=currency,AttributeType=S' --key-schema 'AttributeName=primary_key,KeyType=HASH AttributeName=currency,KeyType=RANGE' --provisioned-throughput 'ReadCapacityUnits=5,WriteCapacityUnits=5'
```

### DELETE-TABLE
```bash
aws dynamodb delete-table --table-name '<table_name>'
```

### DESCRIBE-TABLE
```bash
aws dynamodb describe-table --table-name "FLEX_RULES"
```

### UPDATE-TABLE
Para cambiarles, por ejemplo, las RCU y WCU (a.k.a el # de camareros)
```bash
aws dynamodb update-table --region 'eu-west-1' --table-name '<table_name>' --provisioned-throughput 'ReadCapacityUnits=5,WriteCapacityUnits=600'
```

### QUERY
```bash
aws dynamodb query --table-name '<table_name>' --key-condition-expression 'primary_key = :primary_keyValue' --expression-attribute-values '{":primary_keyValue":{"S": "MAD-LPA-ES"}}'
```

### GET-ITEM
```bash
aws dynamodb get-item --table-name '<table_name>' --key '{"primary_key": {"S": "MAD-LPA-ES"}, "secondary_key": {"S": "USD"}}' > item.json
```
