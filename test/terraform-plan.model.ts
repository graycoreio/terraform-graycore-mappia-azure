// terraform plan json schema https://developer.hashicorp.com/terraform/internals/json-format#plan-representation
export interface TerraformPlan {
  format_version: string;
  terraform_version: string;
  prior_state: State;
  configuration: Record<string, any>;
  planned_values: Values;
  proposed_unknown: Values;
  variables: Record<string, Variable>;
  resource_changes: ResourceChange[];
  resource_drift: ResourceChange[];
  relevant_attributes: Attribute[];
  output_changes: Record<string, Change>;
  checks: Record<string, any>[];
}

export interface State {
  format_version: string;
  terraform_version: string;
  values: Values;
}

export interface Values {
  outputs: Record<string, Output>;
  root_module: Module;
}

export interface Variable {
  value: string;
}

export interface ResourceChange {
  address: string;
  previous_address?: string;
  module_address?: string;
  mode: string;
  type: string;
  name: string;
  index?: number;
  deposed?: string;
  change: Change;
  action_reason?: ActionReason;
}

export interface Attribute {
  resource: string;
  attribute: string[];
}

export interface Change {
  actions: Action[]
  before?: any
  after?: any
  after_unknown?: any
  before_sensitive?: any
  after_sentitive?: any
  replace_paths?: string[][]
}

export interface Output {
  value: string
  type: string
  sensitive: boolean
}

export interface Module {
  resources: Resource[];
  child_modules: ChildModule[];
}

export interface Resource {
  address: string;
  mode: string;
  type: string;
  name: string;
  index?: number;
  provider_name: string;
  schema_version: number;
  values: Record<string, any>;
  sensititve_values: Record<string, any>;
}

export interface ChildModule extends Module {
  address: string;
}

export enum ActionReason {
  REPLACE_BECAUSE_TAINTED = "replace_because_tainted",
  REPLACE_BECAUSE_CANNOT_UPDATE = "replace_because_cannot_update",
  REPLACE_BY_REQUEST = "replace_by_request",
  DELETE_BECAUSE_NO_RESOURCE_CONFIG = "delete_because_no_resource_config",
  DELETE_BECAUSE_NO_MODULE = "delete_because_no_module",
  DELETE_BECAUSE_WRONG_REPETITION = "delete_because_wrong_repetition",
  DELETE_BECAUSE_COUNT_INDEX = "delete_because_count_index",
  DELETE_BECAUSE_EACH_KEY = "delete_because_each_key",
  READ_BECAUSE_CONFIG_UNKNOWN = "read_because_config_unknown",
  READ_BECAUSE_DEPENDENCY_PENDING = "read_because_dependency_pending"
}

export enum Action {
  NO_OP = "no-op",
  CREATE = "create",
  READ = "read",
  UPDATE = "update",
  DELETE = "delete"
}
