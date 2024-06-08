/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  BytesLike,
  FunctionFragment,
  Result,
  Interface,
  EventFragment,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedLogDescription,
  TypedListener,
  TypedContractMethod,
} from "../../../../common";

export interface ISablierV2ComptrollerInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "admin"
      | "flashFee"
      | "isFlashAsset"
      | "protocolFees"
      | "setFlashFee"
      | "setProtocolFee"
      | "toggleFlashAsset"
      | "transferAdmin"
  ): FunctionFragment;

  getEvent(
    nameOrSignatureOrTopic:
      | "SetFlashFee"
      | "SetProtocolFee"
      | "ToggleFlashAsset"
      | "TransferAdmin"
  ): EventFragment;

  encodeFunctionData(functionFragment: "admin", values?: undefined): string;
  encodeFunctionData(functionFragment: "flashFee", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "isFlashAsset",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "protocolFees",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setFlashFee",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "setProtocolFee",
    values: [AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "toggleFlashAsset",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "transferAdmin",
    values: [AddressLike]
  ): string;

  decodeFunctionResult(functionFragment: "admin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "flashFee", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "isFlashAsset",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "protocolFees",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setFlashFee",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setProtocolFee",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "toggleFlashAsset",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferAdmin",
    data: BytesLike
  ): Result;
}

export namespace SetFlashFeeEvent {
  export type InputTuple = [
    admin: AddressLike,
    oldFlashFee: BigNumberish,
    newFlashFee: BigNumberish
  ];
  export type OutputTuple = [
    admin: string,
    oldFlashFee: bigint,
    newFlashFee: bigint
  ];
  export interface OutputObject {
    admin: string;
    oldFlashFee: bigint;
    newFlashFee: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace SetProtocolFeeEvent {
  export type InputTuple = [
    admin: AddressLike,
    asset: AddressLike,
    oldProtocolFee: BigNumberish,
    newProtocolFee: BigNumberish
  ];
  export type OutputTuple = [
    admin: string,
    asset: string,
    oldProtocolFee: bigint,
    newProtocolFee: bigint
  ];
  export interface OutputObject {
    admin: string;
    asset: string;
    oldProtocolFee: bigint;
    newProtocolFee: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace ToggleFlashAssetEvent {
  export type InputTuple = [
    admin: AddressLike,
    asset: AddressLike,
    newFlag: boolean
  ];
  export type OutputTuple = [admin: string, asset: string, newFlag: boolean];
  export interface OutputObject {
    admin: string;
    asset: string;
    newFlag: boolean;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace TransferAdminEvent {
  export type InputTuple = [oldAdmin: AddressLike, newAdmin: AddressLike];
  export type OutputTuple = [oldAdmin: string, newAdmin: string];
  export interface OutputObject {
    oldAdmin: string;
    newAdmin: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export interface ISablierV2Comptroller extends BaseContract {
  connect(runner?: ContractRunner | null): ISablierV2Comptroller;
  waitForDeployment(): Promise<this>;

  interface: ISablierV2ComptrollerInterface;

  queryFilter<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;
  queryFilter<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;

  on<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  on<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  once<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  once<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  listeners<TCEvent extends TypedContractEvent>(
    event: TCEvent
  ): Promise<Array<TypedListener<TCEvent>>>;
  listeners(eventName?: string): Promise<Array<Listener>>;
  removeAllListeners<TCEvent extends TypedContractEvent>(
    event?: TCEvent
  ): Promise<this>;

  admin: TypedContractMethod<[], [string], "view">;

  flashFee: TypedContractMethod<[], [bigint], "view">;

  isFlashAsset: TypedContractMethod<[token: AddressLike], [boolean], "view">;

  protocolFees: TypedContractMethod<[asset: AddressLike], [bigint], "view">;

  setFlashFee: TypedContractMethod<
    [newFlashFee: BigNumberish],
    [void],
    "nonpayable"
  >;

  setProtocolFee: TypedContractMethod<
    [asset: AddressLike, newProtocolFee: BigNumberish],
    [void],
    "nonpayable"
  >;

  toggleFlashAsset: TypedContractMethod<
    [asset: AddressLike],
    [void],
    "nonpayable"
  >;

  transferAdmin: TypedContractMethod<
    [newAdmin: AddressLike],
    [void],
    "nonpayable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "admin"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "flashFee"
  ): TypedContractMethod<[], [bigint], "view">;
  getFunction(
    nameOrSignature: "isFlashAsset"
  ): TypedContractMethod<[token: AddressLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "protocolFees"
  ): TypedContractMethod<[asset: AddressLike], [bigint], "view">;
  getFunction(
    nameOrSignature: "setFlashFee"
  ): TypedContractMethod<[newFlashFee: BigNumberish], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "setProtocolFee"
  ): TypedContractMethod<
    [asset: AddressLike, newProtocolFee: BigNumberish],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "toggleFlashAsset"
  ): TypedContractMethod<[asset: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "transferAdmin"
  ): TypedContractMethod<[newAdmin: AddressLike], [void], "nonpayable">;

  getEvent(
    key: "SetFlashFee"
  ): TypedContractEvent<
    SetFlashFeeEvent.InputTuple,
    SetFlashFeeEvent.OutputTuple,
    SetFlashFeeEvent.OutputObject
  >;
  getEvent(
    key: "SetProtocolFee"
  ): TypedContractEvent<
    SetProtocolFeeEvent.InputTuple,
    SetProtocolFeeEvent.OutputTuple,
    SetProtocolFeeEvent.OutputObject
  >;
  getEvent(
    key: "ToggleFlashAsset"
  ): TypedContractEvent<
    ToggleFlashAssetEvent.InputTuple,
    ToggleFlashAssetEvent.OutputTuple,
    ToggleFlashAssetEvent.OutputObject
  >;
  getEvent(
    key: "TransferAdmin"
  ): TypedContractEvent<
    TransferAdminEvent.InputTuple,
    TransferAdminEvent.OutputTuple,
    TransferAdminEvent.OutputObject
  >;

  filters: {
    "SetFlashFee(address,uint256,uint256)": TypedContractEvent<
      SetFlashFeeEvent.InputTuple,
      SetFlashFeeEvent.OutputTuple,
      SetFlashFeeEvent.OutputObject
    >;
    SetFlashFee: TypedContractEvent<
      SetFlashFeeEvent.InputTuple,
      SetFlashFeeEvent.OutputTuple,
      SetFlashFeeEvent.OutputObject
    >;

    "SetProtocolFee(address,address,uint256,uint256)": TypedContractEvent<
      SetProtocolFeeEvent.InputTuple,
      SetProtocolFeeEvent.OutputTuple,
      SetProtocolFeeEvent.OutputObject
    >;
    SetProtocolFee: TypedContractEvent<
      SetProtocolFeeEvent.InputTuple,
      SetProtocolFeeEvent.OutputTuple,
      SetProtocolFeeEvent.OutputObject
    >;

    "ToggleFlashAsset(address,address,bool)": TypedContractEvent<
      ToggleFlashAssetEvent.InputTuple,
      ToggleFlashAssetEvent.OutputTuple,
      ToggleFlashAssetEvent.OutputObject
    >;
    ToggleFlashAsset: TypedContractEvent<
      ToggleFlashAssetEvent.InputTuple,
      ToggleFlashAssetEvent.OutputTuple,
      ToggleFlashAssetEvent.OutputObject
    >;

    "TransferAdmin(address,address)": TypedContractEvent<
      TransferAdminEvent.InputTuple,
      TransferAdminEvent.OutputTuple,
      TransferAdminEvent.OutputObject
    >;
    TransferAdmin: TypedContractEvent<
      TransferAdminEvent.InputTuple,
      TransferAdminEvent.OutputTuple,
      TransferAdminEvent.OutputObject
    >;
  };
}
