import { exec } from "child_process";
import { promisify } from "util";
import { TerraformPlan, Resource, Module, ResourceChange } from "./terraform-plan.model";

export const terraformPlanAsJson = async (dir: string): Promise<TerraformPlan> => {
  const planFile = 'testplan.bin';

  // create testplan binary
  // await promisify(exec)(`terraform -chdir=${dir} plan -out=${planFile} -input=false 1> /dev/null`);

  return await promisify(exec)(`terraform -chdir=${dir} show -json ${planFile}`)
    .then(({ stderr, stdout }) => JSON.parse(stdout));
}

export const getResourceChangeByAddress = (plan: TerraformPlan, address:string): ResourceChange | undefined => {
  return plan.resource_changes.find(resource => resource.address === address);
}


// export const getPlannedResourceByAddress = (plan: TerraformPlan, address: string): Resource | null => {
//   return searchByAddress(plan.planned_values.root_module, address);
// }

// const searchByAddress = (module: Module, address: string): Resource | null => {
//   for (const resource of module.resources) {
//     if (resource.address === address) {
//       return resource;
//     }
//   }
//   for (const child of module.child_modules) {
//     const result = searchByAddress(child, address);
//     if (result) {
//       return result;
//     }
//   }

//   return null;
// };
