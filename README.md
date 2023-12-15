# kong-plugin-backend-token-creation

## How deploy this plugins

1) clone this repository
2)  execute the following command to create a config map
```
kubectl create configmap backend-token --from-file=./github/kong-plugin-backend-token-creation/kong/plugins/backend-token-creation -n kong-enterprise 
```

3) in the values.yaml of the Kong Gateway data plane add:
```
plugins: 
  configMaps:
  - name: bbackend-token-creation
    pluginName: backend-token-creation
```

4) add custom plugin to Konnect control plane
![Alt text](images/custom-plugin.png?raw=true "Kong - Plugin")


