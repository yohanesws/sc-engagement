package com.example;

import com.hazelcast.client.HazelcastClient;
import com.hazelcast.client.config.ClientConfig;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.core.IList;

public class SampleHazelcast {

	public static final String ADDRESS_NODE_01= "10.1.2.1"+":5701";
	public static final String ADDRESS_NODE_02= "10.1.2.4"+":31420";

	public void init() throws Exception{

		this.putToList();
		this.printList();


	}


	private void putToList(){
		IList<String> items = this.getLhsList();
		for(int i = 0; i < 10 ; i++){
			System.out.println("put Item no " + i);
			items.add("Messages " + i);
		}
		HazelcastClient.shutdownAll();
	}


	private void printList(){
		IList<String> items = this.getRhsList();
		System.out.println("========================");
		while(!items.isEmpty()){
			System.out.println("Get Item no " + items.remove(0));
		}
		HazelcastClient.shutdownAll();
	}


	private IList<String> getLhsList(){
		return this.getClient(SampleHazelcast.ADDRESS_NODE_01).getList("default");
	}

	private IList<String> getRhsList(){
		return this.getClient(SampleHazelcast.ADDRESS_NODE_02).getList("default");
	}

	private HazelcastInstance getClient(String address){
		ClientConfig clientConfig = new ClientConfig();
		clientConfig.getNetworkConfig().addAddress(address);
		clientConfig.getGroupConfig().setName("dev").setPassword("dev-password");
		return HazelcastClient.newHazelcastClient(clientConfig);
	}



	public static void main(String... args){
		try{
			(new SampleHazelcast()).init();
		}catch(Exception e){
			e.printStackTrace();
		}
	}

}
