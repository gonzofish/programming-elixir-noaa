defmodule Noaa do
  @moduledoc """
  Documentation for Noaa.
  """
  require Logger
  require Record

  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def test do
    HTTPoison.get("http://w1.weather.gov/xml/current_obs/KDTO.xml")
      |> handle_response
      |> parse_data
  end

  def handle_response({ :ok, %{ status_code: 200, body: body }}) do
    body |> :binary.bin_to_list
      |> :xmerl_scan.string
  end
  def handle_response({ _, %{ status_code: _status_code, body: error }}) do
    Logger.error error
  end

  def parse_data({ xml, _ }) do
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

    Map.put(parent_info, :children, current_children ++ [Map.put(node_info, :tag_name, to_string(tag_name))])
  end

  def get_xml_info([:xmlText | attributes ], parent_info) do
    { text, _ } = List.pop_at(attributes, -2)

    current_text = Map.get(parent_info, :text)

    Map.put(parent_info, :text, current_text <> String.trim(to_string(text)))
  end
end

# [
#   {
#     :xmlElement,
#     :current_observation,
#     :current_observation,
#     [],
#     {
#       :xmlNamespace,
#       [],
#       [
#         {'xsd', :"http://www.w3.org/2001/XMLSchema"},
#         {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}
#       ]
#     },
#     [],
#     2,
#     [
#       {
#         :xmlAttribute,
#         :version,
#         [], [], [],
#         [current_observation: 2],
#         1,
#         [],
#         '1.0',
#         false
#       },
#       {
#         :xmlAttribute,
#         :"xmlns:xsd",
#         [], {'xmlns', 'xsd'}, [],
#         [current_observation: 2],
#         2,
#         [],
#         'http://www.w3.org/2001/XMLSchema',
#         false
#       },
#       {
#         :xmlAttribute,
#         :"xmlns:xsi",
#         [], {'xmlns', 'xsi'}, [],
#         [current_observation: 2],
#         3,
#         [],
#         'http://www.w3.org/2001/XMLSchema-instance',
#         false
#       },
#       {
#         :xmlAttribute,
#         :"xsi:noNamespaceSchemaLocation",
#         [], {'xsi', 'noNamespaceSchemaLocation'}, [],
#         [current_observation: 2],
#         4,
#         [],
#         'http://www.weather.gov/view/current_observation.xsd',
#         false
#       }
#     ],
#     [
#       {:xmlText, [current_observation: 2], 1, [], '\n\t', :text},
#       {
#         :xmlElement, :credit, :credit, [],
#         {
#         :xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 2, [],
#     [{:xmlText, [credit: 2, current_observation: 2], 1, [],
#       'NOAA\'s National Weather Service', :text}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 3, [], '\n\t', :text},
#    {:xmlElement, :credit_URL, :credit_URL, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 4, [],
#     [{:xmlText, [credit_URL: 4, current_observation: 2], 1, [],
#       'http://weather.gov/', :text}], [], '/Users/gonzofish/webdev/elixir/noaa',
#     :undeclared}, {:xmlText, [current_observation: 2], 5, [], '\n\t', :text},
#    {:xmlElement, :image, :image, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 6, [],
#     [{:xmlText, [image: 6, current_observation: 2], 1, [], '\n\t\t', :text},
#      {:xmlElement, :url, :url, [],
#       {:xmlNamespace, [],
#        [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#         {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#       [image: 6, current_observation: 2], 2, [],
#       [{:xmlText, [url: 2, image: 6, current_observation: 2], 1, [],
#         'http://weather.gov/images/xml_logo.gif', :text}], [],
#       '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#      {:xmlText, [image: 6, current_observation: 2], 3, [], '\n\t\t', :text},
#      {:xmlElement, :title, :title, [],
#       {:xmlNamespace, [],
#        [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#         {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#       [image: 6, current_observation: 2], 4, [],
#       [{:xmlText, [title: 4, image: 6, current_observation: 2], 1, [],
#         'NOAA\'s National Weather Service', :text}], [],
#       '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#      {:xmlText, [image: 6, current_observation: 2], 5, [], '\n\t\t', :text},
#      {:xmlElement, :link, :link, [],
#       {:xmlNamespace, [],
#        [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#         {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#       [image: 6, current_observation: 2], 6, [],
#       [{:xmlText, [link: 6, image: 6, current_observation: 2], 1, [],
#         'http://weather.gov', :text}], [],
#       '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#      {:xmlText, [image: 6, current_observation: 2], 7, [], '\n\t', :text}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 7, [], '\n\t', :text},
#    {:xmlElement, :suggested_pickup, :suggested_pickup, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 8, [],
#     [{:xmlText, [suggested_pickup: 8, current_observation: 2], 1, [],
#       '15 minutes after the hour', :text}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 9, [], '\n\t', :text},
#    {:xmlElement, :suggested_pickup_period, :suggested_pickup_period, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 10, [],
#     [{:xmlText, [suggested_pickup_period: 10, current_observation: 2], 1, [],
#       '60', :text}], [], '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 11, [], '\n\t', :text},
#    {:xmlElement, :location, :location, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 12, [],
#     [{:xmlText, [location: 12, current_observation: 2], 1, [],
#       'Denton Municipal Airport, TX', :text}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 13, [], '\n\t', :text},
#    {:xmlElement, :station_id, :station_id, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 14, [],
#     [{:xmlText, [station_id: 14, current_observation: 2], 1, [], 'KDTO',
#       :text}], [], '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 15, [], '\n\t', :text},
#    {:xmlElement, :latitude, :latitude, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 16, [],
#     [{:xmlText, [latitude: 16, current_observation: 2], 1, [], '33.20505',
#       :text}], [], '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 17, [], '\n\t', :text},
#    {:xmlElement, :longitude, :longitude, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 18, [],
#     [{:xmlText, [longitude: 18, current_observation: 2], 1, [], '-97.20061',
#       :text}], [], '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 19, [], '\n\t', :text},
#    {:xmlElement, :observation_time, :observation_time, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 20, [],
#     [{:xmlText, [observation_time: 20, current_observation: 2], 1, [],
#       'Last Updated on May 9 2017, 6:53 am CDT', :text}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 21, [], '\n        ', :text},
#    {:xmlElement, :observation_time_rfc822, :observation_time_rfc822, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 22, [],
#     [{:xmlText, [observation_time_rfc822: 22, current_observation: 2], 1, [],
#       'Tue, 09 May 2017 06:53:00 -0500', :text}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 23, [], '\n\t', :text},
#    {:xmlElement, :weather, :weather, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 24, [],
#     [{:xmlText, [weather: 24, current_observation: 2], 1, [], 'Fair', :text}],
#     [], '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 25, [], '\n\t', :text},
#    {:xmlElement, :temperature_string, :temperature_string, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 26, [],
#     [{:xmlText, [temperature_string: 26, current_observation: 2], 1, [],
#       '66.0 F (18.9 C)', :text}], [], '/Users/gonzofish/webdev/elixir/noaa',
#     :undeclared}, {:xmlText, [current_observation: 2], 27, [], '\n\t', :text},
#    {:xmlElement, :temp_f, :temp_f, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 28, [],
#     [{:xmlText, [temp_f: 28, current_observation: 2], 1, [], ...}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', :undeclared},
#    {:xmlText, [current_observation: 2], 29, [], '\n\t', :text},
#    {:xmlElement, :temp_c, :temp_c, [],
#     {:xmlNamespace, [],
#      [{'xsd', :"http://www.w3.org/2001/XMLSchema"},
#       {'xsi', :"http://www.w3.org/2001/XMLSchema-instance"}]},
#     [current_observation: 2], 30, [], [{:xmlText, [...], ...}], [],
#     '/Users/gonzofish/webdev/elixir/noaa', ...},
#    {:xmlText, [current_observation: 2], 31, [], '\n\t', :text},
#    {:xmlElement, :relative_humidity, :relative_humidity, [],
#     {:xmlNamespace, [], [{'xsd', ...}, {'xsi', ...}]}, [current_observation: 2],
#     32, [], [...], ...},
#    {:xmlText, [current_observation: 2], 33, [], '\n\t', :text},
#    {:xmlElement, :wind_string, :wind_string, [], {:xmlNamespace, [], ...},
#     [current_observation: 2], 34, ...},
#    {:xmlText, [current_observation: 2], 35, [], '\n\t', :text},
#    {:xmlElement, :wind_dir, :wind_dir, [], {...}, ...},
#    {:xmlText, [current_observation: 2], 37, [], ...},
#    {:xmlElement, :wind_degrees, :wind_degrees, ...}, {:xmlText, [...], ...},
#    {:xmlElement, ...}, {...}, ...],
#     [],
#     '/Users/gonzofish/webdev/elixir/noaa',
#     :undeclared
#   }
# ]