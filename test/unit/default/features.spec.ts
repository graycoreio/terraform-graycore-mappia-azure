import { Action, getResourceChangeByAddress, ResourceChange, setupTerraformTest, TerraformPlan } from "@mappia/terraform-to-js";

describe("The default terraform project plan", () => {
  let terraformPlan: TerraformPlan;

  jest.setTimeout(60000);

  beforeAll(async () => {
    terraformPlan = await setupTerraformTest(__dirname,
      __dirname + '/../../../main.tf',
      'app.terraform.io\\/graycore\\/mappia\\/graycore',
      "..\\/mappia");
  })

  it('should contain planned outputs', async () => {
    expect(terraformPlan.planned_values.outputs).toBeDefined();
    expect(terraformPlan.planned_values.outputs['ip_address']).toBeDefined();
    expect(terraformPlan.planned_values.outputs['full_qualified_domain_name']).toBeDefined();
    expect(terraformPlan.planned_values.outputs['aks_name']).toBeDefined();
    expect(terraformPlan.planned_values.outputs['kube_config_raw']).toBeDefined();
  });

  it('should only have the resource group data source in its prior_state', async () => {
    expect(terraformPlan.prior_state.values.root_module.resources).toBeUndefined();
    expect(terraformPlan.prior_state.values.root_module.child_modules.length).toBe(1);
    expect(terraformPlan.prior_state.values.root_module.child_modules[0].resources.length).toBe(1);
    expect(terraformPlan.prior_state.values.root_module.child_modules[0].resources[0].address)
      .toBe("module.my-terraform-project.data.azurerm_resource_group.mappia_rg");
  });

  describe('keyvault configurations', () => {
    let keyvault: ResourceChange|undefined;

    beforeAll(() => {
      keyvault = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.azurerm_key_vault.mappia-kv");
    });

    it('should contain a keyvault creation plan', async () => {
      expect(keyvault).toBeDefined();
      expect(keyvault?.change.actions).toEqual([Action.CREATE]);
    })

    it('should be a keyvault with a random name', async () => {
      expect(keyvault?.change.after_unknown?.name).toBe(true);
    });

    it('should contain an access policy creation plan for aks with Get permission', async () => {
      const aksPolicy = getResourceChangeByAddress(terraformPlan, 'module.my-terraform-project.azurerm_key_vault_access_policy.aks-access-policy');
      expect(aksPolicy).toBeDefined();
      expect(aksPolicy?.change.actions).toEqual([Action.CREATE]);
      expect(aksPolicy?.change.after?.secret_permissions).toEqual(['Get']);
    });

    it('should contain an access policy creation plan for the service principal with multiple permissions', async () => {
      const spPolicy = getResourceChangeByAddress(terraformPlan, 'module.my-terraform-project.azurerm_key_vault_access_policy.sp-access-policy');
      expect(spPolicy).toBeDefined();
      expect(spPolicy?.change.actions).toEqual([Action.CREATE]);
      expect(spPolicy?.change.after?.secret_permissions).toEqual(['Get', 'Set', 'Delete', 'Purge']);
    });

    it('should contain the magento-encryption-key creation plan', async () => {
      const encryptionKey = getResourceChangeByAddress(terraformPlan, 'module.my-terraform-project.azurerm_key_vault_secret.magento_encryption_key');
      expect(encryptionKey).toBeDefined();
      expect(encryptionKey?.change.actions).toEqual([Action.CREATE]);
      expect(encryptionKey?.change.after?.name).toBe('magento-encryption-key');
    });

    it('should contain the magento-shared-cache-pwd creation plan', async () => {
      const encryptionKey = getResourceChangeByAddress(terraformPlan, 'module.my-terraform-project.azurerm_key_vault_secret.magento_shared_cache_pwd');
      expect(encryptionKey).toBeDefined();
      expect(encryptionKey?.change.actions).toEqual([Action.CREATE]);
      expect(encryptionKey?.change.after?.name).toBe('magento-shared-cache-pwd');
    });
  });

  describe('aks configurations', () => {
    let aks: ResourceChange|undefined;

    beforeAll(() => {
      aks = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.azurerm_kubernetes_cluster.mappia_aks");
    });

    it('should contain random aks_name and dns_prefix creation plan', () => {
      const aksName = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.random_pet.aks_name[0]");
      const dnsPrefix = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.random_pet.dns_prefix[0]");

      expect(aksName).toBeDefined();
      expect(aksName?.change.actions).toEqual([Action.CREATE]);
      expect(dnsPrefix).toBeDefined();
      expect(dnsPrefix?.change.actions).toEqual([Action.CREATE]);
    });

    it('should contain the aks creation plan', async () => {
      expect(aks).toBeDefined();
      expect(aks?.change.actions).toEqual([Action.CREATE]);
      expect(aks?.change.actions).toEqual([Action.CREATE]);
      expect(aks?.change.after?.resource_group_name).toBe('mappia-ci');
      expect(aks?.change.after?.location).toEqual('eastus2');
    });

    it('should create aks with default node pool configurations', async () => {
      expect(aks?.change.after?.default_node_pool[0].linux_os_config[0].sysctl_config[0].vm_max_map_count).toBe(262144);
      expect(aks?.change.after?.default_node_pool[0].name).toBe('agentpool');
      expect(aks?.change.after?.default_node_pool[0].vm_size).toBe('Standard_B2s');
      expect(aks?.change.after?.default_node_pool[0].min_count).toBe(4);
      expect(aks?.change.after?.default_node_pool[0].max_count).toBe(5);
      expect(aks?.change.after?.default_node_pool[0].zones).toBeNull();
    });

    it('should create aks with random name and dns prefix', async () => {
      expect(aks?.change.after_unknown?.name).toBe(true);
      expect(aks?.change.after_unknown?.dns_prefix).toBe(true);
    });

    it('should create aks with kubernetes version 1.23', async () => {
      expect(aks?.change.after?.kubernetes_version).toBe('1.23');
    });

    it('should create aks with system assigned identity', async () => {
      expect(aks?.change.after?.identity[0].type).toBe('SystemAssigned');
    });

    it('should create aks with keyvault secrets provider', async () => {
      expect(aks?.change.after_unknown?.key_vault_secrets_provider[0].secret_identity).toBe(true);
    });
  });

  describe('aks configurations', () => {
    let publicIp: ResourceChange|undefined;

    beforeAll(() => {
      publicIp = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.azurerm_public_ip.mappia_ip");
    });

    it('should contain the public ip creation plan', () => {
      expect(publicIp).toBeDefined();
      expect(publicIp?.change.actions).toEqual([Action.CREATE]);
      expect(publicIp?.change.after?.resource_group_name).toBe('mappia-ci');
    });

    it('should create a static public ip', () => {
      expect(publicIp?.change.after?.allocation_method).toBe('Static');
    });

    it('should create a random domain_name_label', () => {
      const randomDomain = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.random_pet.domain_name[0]");
      expect(randomDomain).toBeDefined();
      expect(randomDomain?.change.actions).toEqual([Action.CREATE]);
      expect(publicIp?.change.after_unknown?.ip_address).toBe(true);
    });

    it('should create a Network Contributor role assignment for aks in the public ip', () => {
      const roleAssignment = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.azurerm_role_assignment.aks_identity_ip_role_permission");
      expect(roleAssignment).toBeDefined();
      expect(roleAssignment?.change.actions).toEqual([Action.CREATE]);
      expect(roleAssignment?.change.after?.role_definition_name).toBe("Network Contributor");
    });
  });

  describe('Helm chart for ingress', () => {
    let ingressChart: ResourceChange|undefined;

    beforeAll(() => {
      ingressChart = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.helm_release.ingress");
    });

    it('should contain the ingress helm chart creation plan', () => {
      expect(ingressChart).toBeDefined();
      expect(ingressChart?.change.actions).toEqual([Action.CREATE]);
      expect(ingressChart?.change.after?.name).toBe('mappia-nginx');
      expect(ingressChart?.change.after?.chart).toBe('ingress-nginx');
      expect(ingressChart?.change.after?.namespace).toBe('ingress-nginx');
      expect(ingressChart?.change.after?.repository).toBe('https://kubernetes.github.io/ingress-nginx/');
    });

    it('should contain azure specific ingress annotations', () => {
      expect(ingressChart?.change.after?.set).toContainEqual({
        name: "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group",
        type: "string",
        value: "mappia-ci"
      });
    });
  });

  describe('Helm chart for akvaks', () => {
    let akvaksChart: ResourceChange|undefined;

    beforeAll(() => {
      akvaksChart = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.helm_release.mappia_kv_to_aks");
    });

    it('should contain the akvaks helm chart creation plan', () => {
      expect(akvaksChart).toBeDefined();
      expect(akvaksChart?.change.actions).toEqual([Action.CREATE]);
      expect(akvaksChart?.change.after?.name).toBe('mappia-kv-to-aks');
      expect(akvaksChart?.change.after?.chart).toBe('akvaks');
      expect(akvaksChart?.change.after?.namespace).toBe('default');
      expect(akvaksChart?.change.after?.repository).toBe('oci://mappia.azurecr.io/helm');
    });
  });

  describe('Mappia infrastructure',  () => {
    let mappiaChart: ResourceChange|undefined;

    beforeAll(() => {
      mappiaChart = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.module.mappia.helm_release.mappia");
    });

    it('should contain the mappia helm chart creation plan', () => {
      expect(mappiaChart).toBeDefined()
      expect(mappiaChart?.change.actions).toEqual([Action.CREATE]);
      expect(mappiaChart?.change.after?.name).toBe('mappia');
      expect(mappiaChart?.change.after?.chart).toBe('mappia');
      expect(mappiaChart?.change.after?.namespace).toBe('default');
      expect(mappiaChart?.change.after?.repository).toBe('oci://mappia.azurecr.io/helm');
    });

    it('should contain the standard storage class creation plan', () => {
      const stdStorageClass = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.kubernetes_storage_class.mappia_writable");

      expect(stdStorageClass).toBeDefined();
      expect(stdStorageClass?.change.actions).toEqual([Action.CREATE]);
      expect(stdStorageClass?.change.after?.metadata[0].name).toBe('azurefile-csi-web-writable');
      expect(stdStorageClass?.change.after?.mount_options).toEqual([
        'cache=strict',
        'dir_mode=0777',
        'file_mode=0777',
        'gid=82',
        'mfsymlinks',
        'nosharesock',
        'uid=82'
      ]);
      expect(stdStorageClass?.change.after?.parameters.skuName).toBe('Standard_LRS');
      expect(stdStorageClass?.change.after?.storage_provisioner).toBe('file.csi.azure.com');
    });

    it('should contain the premium storage class creation plan', () => {
      const stdStorageClass = getResourceChangeByAddress(terraformPlan, "module.my-terraform-project.kubernetes_storage_class.mappia_writable_premium");

      expect(stdStorageClass).toBeDefined();
      expect(stdStorageClass?.change.actions).toEqual([Action.CREATE]);
      expect(stdStorageClass?.change.after?.metadata[0].name).toBe('azurefile-premium-csi-web-writable');
      expect(stdStorageClass?.change.after?.mount_options).toEqual([
        'cache=strict',
        'dir_mode=0777',
        'file_mode=0777',
        'gid=82',
        'mfsymlinks',
        'nosharesock',
        'uid=82'
      ]);
      expect(stdStorageClass?.change.after?.parameters.skuName).toBe('Premium_LRS');
      expect(stdStorageClass?.change.after?.storage_provisioner).toBe('file.csi.azure.com');
    });
  })
});
