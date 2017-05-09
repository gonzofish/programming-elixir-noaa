defmodule Noaa.Parser do
  @moduledoc """
  Provides the mechanism for parsing XML
  data from NOAA.
  """
  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def parse(xml) do
    [root] = :xmerl_xpath.string('/current_observation', xml)
    [%{ children: children }] = Tuple.to_list(root) |> get_xml_info

    children
  end

  def get_xml_info(node) do
    %{ children: children } = get_xml_info(node, %{ children: [], tag_name: :root, text: "" })
    children
  end

  def get_xml_info([:xmlElement, tag_name, _, _, _, _, _, _, children | _tail ], parent_info) do
    current_children = Map.get(parent_info, :children)
    node_info = Enum.reduce(children, %{ children: [], text: "" }, fn(child, acc) ->
      Tuple.to_list(child) |> get_xml_info(acc)
    end)

    Map.put(parent_info, :children, current_children ++ [Map.put(node_info, :tag_name, tag_name)])
  end

  def get_xml_info([:xmlText | attributes ], parent_info) do
    { text, _ } = List.pop_at(attributes, -2)

    current_text = Map.get(parent_info, :text)

    Map.put(parent_info, :text, current_text <> String.trim(to_string(text)))
  end
end
